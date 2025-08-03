require 'spec_helper'

RSpec.describe ClientSearcher do
  
  # @note Use FactoryBot for test data
  let(:client1) { Client.new({ name: 'Alice Johnson', email: 'alice@example.com' }) }
  let(:client2) { Client.new({ name: 'Bob Smith', email: 'bob@example.com' }) }
  let(:client3) { Client.new({ name: 'Alicia Stone', email: 'alice@example.com' }) }
  let(:client4) { Client.new({ name: 'Charlie', email: 'charlie@example.com' }) }

  let(:clients) { [client1, client2, client3, client4] }

  subject(:searcher) { described_class.new(clients) }

  describe '#search_by_field' do
    context 'when searching by name (fuzzy match)' do
      it 'returns matching clients with partial name (case-insensitive)' do
        result = searcher.search_by_field(:name, 'ali')
        expect(result).to contain_exactly(client1, client3)
      end

      it 'returns empty array if no matches found' do
        result = searcher.search_by_field(:name, 'zoe')
        expect(result).to be_empty
      end

      it 'handles missing field gracefully' do
        allow(client1).to receive(:[]).with(:name).and_raise(StandardError)
        result = searcher.search_by_field(:name, 'ali')
        expect(result).to contain_exactly(client3)
      end
    end
  end

  describe '#duplicate_emails' do
    it 'returns all clients with duplicate emails' do
      result = searcher.duplicate_emails
      expect(result).to include(client1, client3)
      expect(result).not_to include(client2, client4)
    end

    it 'returns empty if no duplicates found' do
      no_dupes = [client1, client2, client4] # removing client3
      no_dupe_searcher = described_class.new(no_dupes)
      expect(no_dupe_searcher.duplicate_emails).to be_empty
    end
  end
end
