# spec/client_spec.rb
require 'spec_helper'
require_relative '../lib/client'

RSpec.describe Client do
  let(:attrs) { { 'id' => 1, 'name' => 'Alice', :email => 'alice@example.com' } }
  subject(:client) { described_class.new(attrs) }

  describe '#[]' do
    it 'returns value for string key' do
      expect(client['name']).to eq('Alice')
    end
    it 'returns value for symbol key' do
      expect(client[:email]).to eq('alice@example.com')
    end
    it 'returns nil for missing key' do
      expect(client['missing']).to be_nil
    end
  end

  describe 'dynamic method access' do
    it 'returns value for string key as method' do
      expect(client.name).to eq('Alice')
    end
    it 'returns value for symbol key as method' do
      expect(client.email).to eq('alice@example.com')
    end
    it 'returns nil for missing method' do
      expect(client.missing).to be_nil
    end
  end

  describe '#keys' do
    it 'returns all keys' do
      expect(client.keys).to include('id', 'name', :email)
    end
  end

  describe '#to_s' do
    it 'returns a formatted string of attributes' do
      expect(client.to_s).to include('id: 1')
      expect(client.to_s).to include('name: Alice')
      expect(client.to_s).to include('email: alice@example.com')
    end
  end
end
