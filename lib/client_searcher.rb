class ClientSearcher

  attr_reader :clients

  def initialize(clients)
    @clients = clients
  end

  def search_by_field(field, query)
      clients.select do |client|
      value = begin
        client[field]
      rescue StandardError
        nil
      end

      # nice for fuzzy search
      value.to_s.downcase.include?(query.downcase)
      # Make this for exact match if needed
      # value.to_s.downcase == query.downcase
    end
  end

  def duplicate_emails
    grouped = clients.group_by(&:email)
    grouped.select { |_, list| list.size > 1 }.values.flatten
  end
end
