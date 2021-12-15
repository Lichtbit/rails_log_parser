# frozen_string_literal: true

require 'json'

RailsLogParser::HeuristicStatFile = Struct.new(:path, :date) do
  attr_reader :stats

  class << self
    def build_heuristic(path, today)
      sums = { actions: 0 }
      RailsLogParser::Action::KNOWN_EXCEPTIONS.each_key do |exception|
        sums[exception.to_sym] = 0
      end
      7.times do |i|
        stats = RailsLogParser::HeuristicStatFile.new(path, today.date - (i + 1)).load_stats
        sums[:actions] += stats[:actions].to_i
        RailsLogParser::Action::KNOWN_EXCEPTIONS.each_key do |exception|
          sums[exception.to_sym] += stats.dig(:known_exceptions, exception.to_sym).to_i
        end
      end
      output = {}
      RailsLogParser::Action::KNOWN_EXCEPTIONS.each_key do |exception|
        next if sums[:actions] == 0

        quota = sums[exception.to_sym].to_f / sums[:actions]
        today_quota = today.rate(exception)
        next if today_quota == 0

        rate = ((today_quota - quota) / quota) / Math.sqrt(sums[:actions].to_f)
        output[exception] = rate if rate > heuristic_threshold
      end
      output
    end

    def heuristic_threshold
      @heuristic_threshold ||= ENV['RAILS_LOG_PARSER_THRESHOLD_HEURISTIC'] || RailsLogParser::THRESHOLD_HEURISTIC
    end
  end

  def write_stats(actions)
    actions = actions.select { |action| action.datetime.to_date == date }.sort_by(&:datetime)
    @stats = {
      actions: actions.count,
      known_exceptions: {},
      starts_at: actions.first&.datetime,
      ends_at: actions.last&.datetime,
    }

    RailsLogParser::Action::KNOWN_EXCEPTIONS.each_key do |exception|
      @stats[:known_exceptions][exception.to_sym] = actions.count { |action| action.known_exception?(exception) }
    end
    File.write(heuristic_file_path, @stats.to_json)
  end

  def load_stats
    @stats = JSON.parse(File.read(heuristic_file_path), symbolize_names: true) if File.file?(heuristic_file_path)
    @stats ||= {}
  rescue JSON::ParserError
    @stats = {}
  end

  def heuristic_file_path
    @heuristic_file_path ||= File.join(path, "heuristic_stats_#{date}.json")
  end

  def rate(exception)
    return 0 if stats[:actions] == 0

    stats.dig(:known_exceptions, exception.to_sym).to_f / stats[:actions]
  end
end
