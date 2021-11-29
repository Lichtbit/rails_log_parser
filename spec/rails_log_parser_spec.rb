# frozen_string_literal: true

RSpec.describe RailsLogParser do
  let(:file_path) { File.join(__dir__, 'fixtures/example.log') }
  let(:parser) { RailsLogParser::Parser.from_file(file_path) }

  describe '.from_file' do
    it 'parses file' do
      expect(parser.actions.count).to eq 11
      expect(parser.actions.count(&:fatal?)).to eq 4
      expect(parser.actions.count(&:info?)).to eq 6
      expect(parser.actions.count(&:warn?)).to eq 1
      expect(parser.actions.count(&:without_request?)).to eq 3
      expect(parser.actions.select(&:fatal?).map(&:headline)).to eq [
        "ActiveRecord::RecordNotFound (Couldn't find Foobars::CenterFoo):",
        'ActionController::RoutingError (No route matches [OPTIONS] "/c....',
        "ActiveModel::MissingAttributeError (can't write unknown attribute `consent_privacy`):",
        'ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):',
      ]
      expect(parser.actions.select(&:known_exception?).map(&:headline)).to eq [
        "ActiveRecord::RecordNotFound (Couldn't find Foobars::CenterFoo):",
        'ActionController::RoutingError (No route matches [OPTIONS] "/c....',
        'ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):',
      ]
    end
  end

  describe '#summary' do
    it 'generats summary' do
      expect(parser.summary).to eq <<~TEXT
        1 lines with warn:
          Creating scope :for_foo. Overwriting existing method Foobar::CenterFoo.for_foo.



        1 lines with fatal:
          ActiveModel::MissingAttributeError (can't write unknown attribute `consent_privacy`):


      TEXT
    end
  end
end
