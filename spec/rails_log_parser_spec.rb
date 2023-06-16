# frozen_string_literal: true

require 'tmpdir'

RSpec.describe RailsLogParser do
  let(:file_path) { File.join(__dir__, 'fixtures/example.log') }
  let(:parser) { RailsLogParser::Parser.from_file(file_path) }

  describe '.from_file' do
    it 'parses file' do
      expect(parser.actions.count).to eq 14
      expect(parser.actions.count(&:fatal?)).to eq 7
      expect(parser.actions.count(&:info?)).to eq 6
      expect(parser.actions.count(&:warn?)).to eq 1
      expect(parser.actions.count(&:without_request?)).to eq 3
      expect(parser.actions.select(&:fatal?).map(&:headline)).to eq [
        'ActionController::UnfilteredParameters (unable to convert unpermitted parameters to hash):',
        'ActiveRecord::RecordNotFound (Couldn\'t find Foobars::CenterFoo):',
        'ActionController::RoutingError (No route matches [OPTIONS] "/c....',
        "ActiveModel::MissingAttributeError (can't write unknown attribute `consent_privacy`):",
        'ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):',
        'URI::InvalidURIError (bad URI(is not URI?): "https://example.de/c..../%{all}"):',
        'ActionView::Template::Error (PG::UndefinedColumn: ERROR:  column foos.first_name does not exist',
      ]
      expect(parser.actions.select(&:known_exception?).map(&:headline)).to eq [
        'ActionController::UnfilteredParameters (unable to convert unpermitted parameters to hash):',
        'ActiveRecord::RecordNotFound (Couldn\'t find Foobars::CenterFoo):',
        'ActionController::RoutingError (No route matches [OPTIONS] "/c....',
        'ActionController::InvalidAuthenticityToken (ActionController::InvalidAuthenticityToken):',
      ]
    end
  end

  describe '#summary' do
    it 'generates summary' do
      expect(parser.summary).to eq <<~TEXT
        1 lines with warn:
          Creating scope :for_foo. Overwriting existing method Foobar::CenterFoo.for_foo.



        3 lines with fatal:
          ActiveModel::MissingAttributeError (can't write unknown attribute `consent_privacy`):
          URI::InvalidURIError (bad URI(is not URI?): "https://example.de/c..../%{all}"):
          ActionView::Template::Error (PG::UndefinedColumn: ERROR:  column foos.first_name does not exist


      TEXT
    end
  end

  context 'with empty lines' do
    let(:file_path) { File.join(__dir__, 'fixtures/example2.log') }

    describe '.from_file' do
      it 'parses file' do
        expect(parser.actions.count).to eq 11
        expect(parser.actions.count(&:fatal?)).to eq 1
        expect(parser.actions.count(&:info?)).to eq 10
        expect(parser.actions.count(&:warn?)).to eq 0
        expect(parser.actions.count(&:without_request?)).to eq 0
        expect(parser.not_parseable_lines.lines.count).to eq 0
        expect(parser.actions.select(&:fatal?).map(&:headline)).to eq [
          'ActionView::Template::Error (PG::UndefinedColumn: ERROR:  column series_rounds.name does not exist'
        ]
        expect(parser.actions.select(&:known_exception?).map(&:headline)).to eq []
      end
    end
  end
end
