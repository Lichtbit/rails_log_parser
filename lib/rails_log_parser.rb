# frozen_string_literal: true

require 'enumerize'

module RailsLogParser
  THRESHOLD_HEURISTIC = 0.02
end

require_relative 'rails_log_parser/parser'
require_relative 'rails_log_parser/action'
require_relative 'rails_log_parser/line'
require_relative 'rails_log_parser/heuristic_stat_file'
require_relative 'rails_log_parser/not_parseable_lines'

require 'rails_log_parser/railtie' if defined?(Rails::Railtie)
