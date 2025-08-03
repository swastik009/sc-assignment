## app/api/api_controller.rb
require 'json'
DEFAULT_PAGE = 1
DEFAULT_PER_PAGE = 5

class ApiController
  def initialize(clients, keys, searcher)
    @clients = clients
    @keys = keys
    @searcher = searcher
  end

  # Routes the incoming HTTP request to the appropriate API endpoint.
  #
  # @param req [WEBrick::HTTPRequest] The incoming request object.
  # @return [Array] Rack-style response: [status, headers, body]
  #
  # @example
  #   GET /api/list?page=2&per_page=3
  #   GET /api/search?field=email&query=alice@example.com&page=1&per_page=2
  def route(req)
    path = req.path
    params = req.query
    case path
    when '/api/keys'
      keys_endpoint
    when '/api/list'
      list_endpoint(params)
    when '/api/duplicates'
      duplicates_endpoint(params)
    when '/api/search'
      search_endpoint(params)
    else
      response_json({ error: 'Not found' }, 404)
    end
  end

  # Returns all available keys/fields for searching.
  #
  # @return [Array] JSON array of field names.
  #
  # @example
  #   GET /api/keys
  def keys_endpoint
    response_json(@keys)
  end

  # Returns a paginated list of all clients.
  #
  # @param params [Hash] Query params: page, per_page
  # @return [Hash] JSON response with clients and pagination info.
  #
  # @example
  #   GET /api/list?page=2&per_page=3
  def list_endpoint(params)
    page, per_page = extract_pagination(params)
    paginated = paginate(@clients, page, per_page)
    response_json({ page: page, per_page: per_page, total: @clients.size, clients: paginated })
  end

  # Returns a paginated list of clients with duplicate emails.
  #
  # @param params [Hash] Query params: page, per_page
  # @return [Hash] JSON response with duplicates and pagination info.
  #
  # @example
  #   GET /api/duplicates?page=1&per_page=2
  def duplicates_endpoint(params)
    dups = @searcher.duplicate_emails
    page, per_page = extract_pagination(params)
    paginated = paginate(dups, page, per_page)
    response_json({ page: page, per_page: per_page, total: dups.size, duplicates: paginated })
  end

  # Searches clients by a given field and query, paginated.
  #
  # @param params [Hash] Query params: field, query, page, per_page
  # @return [Hash] JSON response with search results and pagination info.
  #
  # @example
  #   GET /api/search?field=email&query=alice@example.com&page=1&per_page=2
  def search_endpoint(params)
    field = params['field']
    query = params['query']
    unless field && query
      return response_json({ error: 'Missing field or query parameter' }, 400)
    end
    results = @searcher.search_by_field(field, query)
    page, per_page = extract_pagination(params)
    paginated = paginate(results, page, per_page)
    response_json({ page: page, per_page: per_page, total: results.size, results: paginated })
  end

  def extract_pagination(params)
    page = (params['page'] || DEFAULT_PAGE).to_i
    per_page = (params['per_page'] || DEFAULT_PER_PAGE).to_i
    [page, per_page]
  end

  # Paginates an array of items.
  #
  # @param arr [Array] The array to paginate.
  # @param page [Integer] The page number (1-based).
  # @param per_page [Integer] The number of items per page.
  # @return [Array] The paginated slice of the array.
  #
  # @example Paginate a list of clients
  #   clients = ["a", "b", "c", "d", "e", "f"]
  #   paginate(clients, 2, 2) #=> ["c", "d"]
  def paginate(arr, page, per_page)
    start_index = (page - 1) * per_page
    end_index = start_index + per_page
    arr[start_index...end_index] || []
  end

  def response_json(obj, status = 200)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(obj)]]
  end
end
