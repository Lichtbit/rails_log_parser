# frozen_string_literal: true

RSpec.describe RailsLogParser::HeuristicStatFile do
  let(:fixture_path) { File.join(__dir__, 'fixtures') }
  let(:parser) { RailsLogParser::Parser.from_file(file_path) }

  describe '.build_heuristic' do
    context 'when today is 2021-12-12' do
      let(:date) { Date.parse('2021-12-12') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActiveRecord::RecordNotFound' => 0.011443875117185698,
        )
      end
    end

    context 'when today is 2021-12-11' do
      let(:date) { Date.parse('2021-12-11') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActionController::RoutingError' => 0.01061809843316415,
        )
      end
    end

    context 'when today is 2021-12-10' do
      let(:date) { Date.parse('2021-12-10') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActionController::InvalidAuthenticityToken' => 0.010560302849964046,
        )
      end
    end

    context 'when today is 2021-12-09' do
      let(:date) { Date.parse('2021-12-09') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq({})
      end
    end

    context 'when today is 2021-12-08' do
      let(:date) { Date.parse('2021-12-08') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActiveRecord::RecordNotFound' => 0.010111883572196443,
        )
      end
    end
  end
end