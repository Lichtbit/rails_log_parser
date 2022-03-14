# frozen_string_literal: true

RSpec.describe RailsLogParser::NotParseableLines do
  describe '#push' do
    let(:current_path) { File.join(File.dirname(RailsLogParser::Parser.log_path), 'not_parseable_lines.json') }

    it 'saves line if not already pushed today' do
      not_parseable_lines = described_class.new
      not_parseable_lines.push('line1')
      expect(not_parseable_lines.lines).to eq ['line1']
      not_parseable_lines.save

      expect(File.read(current_path)).to eq({ Date.today.to_s => ['line1'] }.to_json)
    end
  end
end
