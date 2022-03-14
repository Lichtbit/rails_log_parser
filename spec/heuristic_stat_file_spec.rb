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
          'ActiveRecord::RecordNotFound' => 0.020452809286129837,
        )
      end
    end

    context 'when today is 2021-12-11' do
      let(:date) { Date.parse('2021-12-11') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActionController::RoutingError' => 0.02072690106763237,
        )
      end
    end

    context 'when today is 2021-12-10' do
      let(:date) { Date.parse('2021-12-10') }

      it 'rates known exceptions' do
        heuristic_today = described_class.new(fixture_path, date)
        heuristic_today.load_stats
        expect(described_class.build_heuristic(fixture_path, heuristic_today)).to eq(
          'ActionController::InvalidAuthenticityToken' => 0.020738692557993016,
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
          'ActiveRecord::RecordNotFound' => 0.024915118043906583,
        )
      end
    end
  end

  describe '#delete_old_stats' do
    let(:date) { Date.today }
    let(:path) { File.dirname(RailsLogParser::Parser.log_path) }

    it 'deletes old stat files' do
      (0..39).map { |i| (Date.today - i) }.each do |date|
        File.write(File.join(path, "heuristic_stats_#{date}.json"), "1")
      end
      expect(Dir[File.join(path, "*.json")].count).to eq 40

      RailsLogParser::HeuristicStatFile.new(path, date).delete_old_stats
      expect(Dir[File.join(path, "*.json")].count).to eq 20
    end
  end
end
