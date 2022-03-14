# frozen_string_literal: true

require 'bundler/setup'
require 'rails_log_parser'
require 'tmpdir'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.around do |example|
    Dir.mktmpdir do |dir|
      RailsLogParser::Parser.log_path = File.join(dir, 'production.log')
      example.run
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
