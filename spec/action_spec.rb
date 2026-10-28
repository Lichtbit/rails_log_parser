# frozen_string_literal: true

RSpec.describe RailsLogParser::Action do
  let(:action) { described_class.new(:request, 'id') }

  it 'keeps the highest severity' do
    action.severity = 'INFO'
    action.severity = 'FATAL'
    action.severity = 'WARN'

    expect(action.severity).to eq :fatal
    expect(action).to be_fatal
    expect(action).not_to be_info
  end

  it 'has type predicates' do
    expect(action).to be_request
    expect(action).not_to be_active_job
  end

  it 'rejects unknown types' do
    expect { described_class.new(:foo, 'id') }.to raise_error(ArgumentError)
  end

  it 'is not after a datetime without own datetime' do
    expect(action.after?(Time.now)).to be false
  end
end
