# frozen_string_literal: true

RSpec.describe RailsLogParser::Parser do
  let(:datetime) { Time.now.strftime('%Y-%m-%dT%H:%M:%S.%6N') }
  let(:parser) { RailsLogParser::Parser.from_io(StringIO.new(lines.join("\n"))) }

  context 'with a continuation line of a request outside the log' do
    let(:lines) do
      [
        '[5a671a79-df26-48df-8093-983388f8e482] actionpack (8.1.0) lib/action_dispatch/middleware/static.rb:27',
        "F, [#{datetime} #1] FATAL -- : [b42b65ab-7985-4bc2-a5b5-1fb23e6ad940] NoMethodError (undefined method)",
      ]
    end

    it 'ignores the line' do
      expect(parser.actions.map(&:headline)).to eq ['NoMethodError (undefined method)']
      expect(parser.not_parseable_lines.lines).to eq []
      expect(parser.summary(last_minutes: 20)).to include('1 lines with fatal')
    end
  end

  context 'with a message using the label ANY' do
    let(:lines) { ["U, [#{datetime} #1]   ANY -- : [b42b65ab-7985-4bc2-a5b5-1fb23e6ad940] something"] }

    it 'parses the line without severity' do
      expect(parser.actions.map(&:severity)).to eq [nil]
      expect(parser.summary).to eq ''
    end
  end

  context 'with delayed job lines' do
    let(:lines) do
      [
        "I, [#{datetime} #1]  INFO -- : 2021-11-26T13:51:30+0000: [Worker(delayed_job host:production pid:1)] " \
        '19 jobs processed at 2.8816 j/s, 0 failed',
        "I, [#{datetime} #1]  INFO -- : 2021-11-26T13:51:30+0000: [Worker(delayed_job host:production pid:1)] " \
        'Starting job worker',
        "E, [#{datetime} #1] ERROR -- : Starting job failed: Errno::ENOENT",
      ]
    end

    it 'ignores only the worker status lines' do
      expect(parser.actions.map(&:headline)).to eq ['Starting job failed: Errno::ENOENT']
      expect(parser.actions.map(&:severity)).to eq [:error]
    end
  end
end
