# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'rails_log_parser'
  spec.version       = '0.0.6'
  spec.authors       = ['Georg Limbach']
  spec.email         = ['georg.limbach@lichtbit.com']

  spec.summary       = 'Simple and fast analysing of default rails logs'
  spec.description   = 'If you want to get an email with errors and fatal log lines you can use this gem.'
  spec.homepage      = 'https://github.com/Lichtbit/rails_log_parser'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Lichtbit/rails_log_parser'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'enumerize', '~> 2.4'
  spec.add_dependency 'json'
  spec.add_development_dependency 'rspec'
end
