# spec/client_loader_spec.rb

require 'spec_helper'

RSpec.describe ClientLoader do
  let(:path) { 'fake/path.json' }
  before do
    allow(File).to receive(:read).and_return('')
  end

  context 'with valid data' do
    let(:data) do
      [
        { 'id' => 1, 'full_name' => 'Alice', 'email' => 'alice@example.com' },
        { 'id' => 2, 'full_name' => 'Bob', 'email' => 'bob@example.com' }
      ]
    end

    let(:data_with_missing_keys) do
      [
        { 'foo' => 'bar' }
      ]
    end

    it 'loads clients from a valid JSON file' do
      allow(Oj).to receive(:strict_load).and_return(data)
      clients, keys = described_class.load(path)
      expect(clients.size).to eq(2)
      expect(clients.first).to be_a(Client)
      expect(keys).to include('id', 'full_name', 'email')
    end

    it 'handles missing keys in records' do
      allow(Oj).to receive(:strict_load).and_return(data_with_missing_keys)
      clients, keys = described_class.load(path)
      expect(clients.first['foo']).to eq('bar')
      expect(keys).to eq(['foo'])
    end
  end

  context 'with invalid or empty data' do
    it 'returns empty array for empty file' do
      allow(Oj).to receive(:strict_load).and_return([])
      clients, keys = described_class.load(path)
      expect(clients).to eq([])
      expect(keys).to eq([])
    end

    it 'returns empty array for invalid JSON' do
      allow(Oj).to receive(:strict_load).and_raise(Oj::ParseError.new('bad json'))
      clients, keys = described_class.load(path)
      expect(clients).to eq([])
      expect(keys).to eq([])
    end

    it 'returns empty array if file not found' do
      allow(File).to receive(:read).with('missing.json').and_raise(Errno::ENOENT)
      expect(described_class.load('missing.json').first).to eq([])
    end
  end
end
