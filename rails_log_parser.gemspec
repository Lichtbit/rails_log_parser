# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'rails_log_parser'
  spec.version       = '0.1.0'
  spec.authors       = ['Georg Limbach']
  spec.email         = ['georg.limbach@lichtbit.com']

  spec.summary       = 'Simple and fast analysing of default rails logs'
  spec.description   = 'If you want to get an email with errors and fatal log lines you can use this gem.'
  spec.homepage      = 'https://github.com/Lichtbit/rails_log_parser'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata['source_code_uri'] = 'https://github.com/Lichtbit/rails_log_parser'
  spec.metadata['changelog_uri'] = 'https://github.com/Lichtbit/rails_log_parser/blob/master/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.0', '< 9'
end
