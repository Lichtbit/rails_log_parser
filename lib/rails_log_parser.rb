# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/numeric/time'

module RailsLogParser
  mattr_accessor :ignore_lines, default: []

  def self.configure
    yield self
  end
end

require_relative 'rails_log_parser/parser'
require_relative 'rails_log_parser/action'
require_relative 'rails_log_parser/line'
require_relative 'rails_log_parser/not_parseable_lines'

require 'rails_log_parser/railtie' if defined?(Rails::Railtie)
