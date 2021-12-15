# frozen_string_literal: true

namespace :rails_log_parser do
  desc 'notify about found problems in production.log'
  task :parse, [:from_minutes, :heuristic] do |_t, args|
    parser = RailsLogParser::Parser.from_file(RailsLogParser::Parser.log_path)
    parser.enable_heuristic(File.dirname(RailsLogParser::Parser.log_path)) if args[:heuristic] == 'true'
    print parser.summary(last_minutes: args[:from_minutes])
  end
end
