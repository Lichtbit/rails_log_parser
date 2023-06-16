# frozen_string_literal: true

namespace :rails_log_parser do
  desc 'notify about found problems in production.log'
  task :parse, [:from_minutes] do |_t, args|
    parser = RailsLogParser::Parser.from_file(RailsLogParser::Parser.log_path)
    print parser.summary(last_minutes: args[:from_minutes])
  end
end
