# frozen_string_literal: true

require 'rails_log_parser'
require 'rails'

class RailsLogParser::Railtie < Rails::Railtie
  rake_tasks do
    load 'rails_log_parser/tasks.rb'
  end
end
