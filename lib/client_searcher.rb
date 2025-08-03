##
# ClientSearcher provides search and duplicate detection for client records.
#
# Supports searching by any field and finding clients with duplicate emails.
#
# @example Search by field
#   searcher = ClientSearcher.new(clients)
#   results = searcher.search_by_field('name', 'Alice')
#
# @example Find duplicates
#   duplicates = searcher.duplicate_emails
class ClientSearcher
  # @return [Array<Client>] The array of client objects to search.
  attr_reader :clients

  ##
  # Initializes a new ClientSearcher with the given clients.
  #
  # @param clients [Array<Client>] The array of client objects.
  def initialize(clients)
    @clients = clients
  end

  ##
  # Searches clients by a given field and query (case-insensitive, fuzzy match).
  #
  # @param field [String, Symbol] The field to search.
  # @param query [String] The query string to match.
  # @return [Array<Client>] The clients matching the query.
  def search_by_field(field, query)
    clients.select do |client|
      value = begin
        client[field]
      rescue StandardError
        nil
      end

      # Fuzzy search: checks if value includes query (case-insensitive)
      value.to_s.downcase.include?(query.downcase)
      # For exact match, use:
      # value.to_s.downcase == query.downcase
    end
  end

  ##
  # Finds clients with duplicate email addresses.
  #
  # @return [Array<Client>] The clients with duplicate emails.
  def duplicate_emails
    emails = clients.map { |c| c[:email] }
    clients.select { |c| emails.count(c[:email]) > 1 }
  end
end
