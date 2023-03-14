# frozen_string_literal: true

class RailsLogParser::Parser
  class << self
    attr_writer :log_path

    def log_path
      @log_path || ENV['LOG_PATH']
    end

    def from_file(path)
      parser = new
      File.open(path, 'r') do |handle|
        while (line = handle.gets)
          parser.puts(line)
        end
      end
      parser
    end
  end

  attr_reader :not_parseable_lines

  def initialize
    @actions = {}
    @not_parseable_lines = RailsLogParser::NotParseableLines.new
    @heuristic = nil
  end

  def enable_heuristic(path)
    @heuristic = path
    @heuristic_today = RailsLogParser::HeuristicStatFile.new(@heuristic, Date.today).tap { |p| p.write_stats(actions) }
  end

  def summary(last_minutes: nil)
    relevant = actions
    if last_minutes.present?
      from = last_minutes.to_i.minutes.ago
      relevant = relevant.select { |a| a.after?(from) }
    end
    summary_output = []
    if @not_parseable_lines.lines.present?
      summary_output.push('Not parseable lines:')
      summary_output += @not_parseable_lines.lines.map { |line| "  #{line}" }
      summary_output.push("\n\n")
      @not_parseable_lines.save
    end

    %i[warn error fatal].each do |severity|
      selected = relevant.select { |a| a.public_send("#{severity}?") }.reject(&:known_exception?)
      next if selected.blank?

      summary_output.push("#{selected.count} lines with #{severity}:")
      summary_output += selected.map(&:headline).map { |line| "  #{line}" }
      summary_output.push("\n\n")
    end

    unless @heuristic.nil?
      stats = RailsLogParser::HeuristicStatFile.build_heuristic(@heuristic, @heuristic_today)
      if stats.present?
        summary_output.push("Heuristic match! (threshold: #{RailsLogParser::HeuristicStatFile.heuristic_threshold})")
        stats.each { |k, v| summary_output.push("- #{k}: #{v.round(4)}") }
        summary_output.push("\n\n")
      end
    end

    summary_output.join("\n")
  end

  def actions
    @actions.values
  end

  def puts(line)
    RailsLogParser::Line.new(self, line.encode('UTF-8', invalid: :replace))
  end

  def action(type, params)
    @actions[params['id']] ||= RailsLogParser::Action.new(type, params['id'])
    @actions[params['id']].severity = params['severity_label']
    @actions[params['id']].datetime = params['datetime']
    @actions[params['id']].add_message(params['message']) unless params['message'].nil?
  end

  def request(params)
    action(:request, params)
  end

  def empty_line(params)
    params = params.named_captures
    params['message'] = nil
    action(:request, params)
  end

  def without_request(params)
    params = params.named_captures
    params['id'] = SecureRandom.uuid
    action(:without_request, params)
  end

  def active_job(params)
    action(:active_job, params)
  end

  def delayed_job(params)
    action(:delayed_job, params)
  end

  def add_message(params)
    @actions[params['id']] ||= RailsLogParser::Action.new(type, params['id'])
    @actions[params['id']].add_message(params['message'])
  end

  def last_action
    RailsLogParser::Action.last
  end
end
