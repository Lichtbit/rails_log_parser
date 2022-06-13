# frozen_string_literal: true

require 'enumerize'

module RailsLogParser
  THRESHOLD_HEURISTIC = 0.02
  MIN_ACTIONS_HEURISTIC = 100000 # sum of last 10 days
end

require_relative 'rails_log_parser/parser'
require_relative 'rails_log_parser/action'
require_relative 'rails_log_parser/line'
require_relative 'rails_log_parser/heuristic_stat_file'
require_relative 'rails_log_parser/not_parseable_lines'

require 'rails_log_parser/railtie' if defined?(Rails::Railtie)
