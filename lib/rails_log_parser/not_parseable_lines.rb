# frozen_string_literal: true

require 'json'

class RailsLogParser::NotParseableLines
  attr_reader :lines

  def initialize
    @lines = []
    @path = File.join(File.dirname(RailsLogParser::Parser.log_path), 'not_parseable_lines.json')
    load_file
  end

  def push(line)
    @lines.push(line) unless today_lines.include?(line)
  end

  def save
    @stats[Date.today.to_s] = today_lines + lines

    last_7_days = (0..6).map { |i| (Date.today - i) }.map(&:to_s)
    @stats.each_key do |key|
      @stats.delete(key) unless last_7_days.include?(key)
    end
    File.write(@path, @stats.to_json)
  end

  protected

  def today_lines
    @stats[Date.today.to_s] || []
  end

  def load_file
    @stats = JSON.parse(File.read(@path))
    @stats ||= {}
  rescue JSON::ParserError, Errno::ENOENT
    @stats = {}
  end
end
