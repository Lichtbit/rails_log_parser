# frozen_string_literal: true

require 'enumerize'

module RailsLogParser
end

require_relative 'rails_log_parser/parser'
require_relative 'rails_log_parser/action'
require_relative 'rails_log_parser/line'

require 'rails_log_parser/railtie' if defined?(Rails::Railtie)
