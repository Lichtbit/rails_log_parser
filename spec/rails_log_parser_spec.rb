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

    context 'when heuristic return bad rates' do
      before do
        parser.instance_variable_set(:@heuristic, 'path')
        expect(RailsLogParser::HeuristicStatFile).to receive(:build_heuristic).and_return({ 'Error' => 0.02235 })
      end

      it 'generates more text' do
        expect(parser.summary).to eq <<~TEXT
          1 lines with warn:
            Creating scope :for_foo. Overwriting existing method Foobar::CenterFoo.for_foo.



          3 lines with fatal:
            ActiveModel::MissingAttributeError (can't write unknown attribute `consent_privacy`):
            URI::InvalidURIError (bad URI(is not URI?): "https://example.de/c..../%{all}"):
            ActionView::Template::Error (PG::UndefinedColumn: ERROR:  column foos.first_name does not exist



          Heuristic match! (threshold: 0.02)
          - Error: 0.0224


        TEXT
      end
    end

    context 'when heuristic return no rates and actions are empty' do
      before do
        parser.instance_variable_set(:@heuristic, 'path')
        parser.instance_variable_set(:@actions, {})
        expect(RailsLogParser::HeuristicStatFile).to receive(:build_heuristic).and_return({})
      end

      it 'generates more text' do
        expect(parser.summary).to eq ''
      end
    end
  end

  describe '#enable_heuristic' do
    it 'enables heuristic with stat files at path' do
      allow(Date).to receive(:today).and_return(Date.parse('2021-11-26'))

      Dir.mktmpdir do |dir|
        expect(File).to receive(:write).with(
          File.join(dir, 'heuristic_stats_2021-11-26.json'),
          "{\"actions\":14,\"known_exceptions\":{" \
            "\"Can't verify CSRF token authenticity.\":0," \
            "\"ActionController::InvalidAuthenticityToken\":1," \
            "\"ActionController::RoutingError\":1," \
            "\"ActionController::UnfilteredParameters\":1," \
            "\"ActionController::UnknownFormat\":0," \
            "\"ActiveRecord::RecordNotFound\":1" \
          "},\"starts_at\":\"2021-11-26 00:00:35 +0100\",\"ends_at\":\"2021-11-26 12:26:19 +0100\"}",
        )

        parser.enable_heuristic(dir)
        expect(parser.instance_variable_get(:@heuristic)).to eq dir
      end
    end
  end
end
