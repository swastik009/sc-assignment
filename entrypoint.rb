##
# Entrypoint for the ShiftCare API server.
#
# Starts a WEBrick HTTP server, serves Swagger UI, swagger.json, and API endpoints.
# Implements in-memory request throttling per IP address.
#
# Usage:
#   ruby entrypoint.rb [data_file]
#
# @example Start the server with default data file
#   ruby entrypoint.rb
#
# @example Start the server with a custom data file
#   ruby entrypoint.rb data/clients.json
require_relative 'app/api/app_loader'

# Maximum requests allowed per IP per window (seconds)
# @return [Integer]
REQUEST_LIMIT = 60
# Throttle window in seconds
# @return [Integer]
THROTTLE_WINDOW = 60

if __FILE__ == $0
  ##
  # Path to the client data file (default: data/clients.json)
  # @return [String]
  file_path = ARGV[0] || 'data/clients.json'
  loader = AppLoader.new(file_path)
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: 9292, DocumentRoot: File.expand_path('public', __dir__))

  # Simple in-memory request throttling (per IP, per minute)
  # @param ip [String] Remote IP address
  # @return [Boolean] True if throttled, false otherwise
  request_counts = Hash.new { |h, k| h[k] = [] }

  throttled = lambda do |ip|
    now = Time.now.to_i
    # Remove any request timestamps for this IP that are older than the current throttle window.
    # This keeps only recent requests (within the last THROTTLE_WINDOW seconds),
    # ensuring that rate limiting is enforced for the correct time period and
    # prevents the request history from growing indefinitely.
    # For example, if THROTTLE_WINDOW is 60, only requests from the last 60 seconds are counted.
    request_counts[ip].reject! { |t| t < now - THROTTLE_WINDOW }
    if request_counts[ip].size >= REQUEST_LIMIT
      true
    else
      request_counts[ip] << now
      false
    end
  end

  ##
  # Serves Swagger UI at root path ('/')
  server.mount '/', WEBrick::HTTPServlet::FileHandler, File.expand_path('public/swagger-ui/index.html', __dir__)

  ##
  # Serves swagger.json with correct Content-Type and throttling
  server.mount_proc '/swagger.json' do |req, res|
    if throttled.call(req.remote_ip)
      res.status = 429
      res.body = '{"error":"Too Many Requests"}'
      next
    end
    res['Content-Type'] = 'application/json'
    res.body = File.read(File.expand_path('public/swagger.json', __dir__))
  end

  ##
  # Serves API endpoints at /api, with request throttling
  server.mount_proc '/api' do |req, res|
    if throttled.call(req.remote_ip)
      res.status = 429
      res.body = '{"error":"Too Many Requests"}'
      next
    end
    status, headers, body = loader.api_controller.route(req)
    res.status = status
    headers.each { |k, v| res[k] = v }
    res.body = body.join
  end

  trap('INT') { server.shutdown }
  puts 'Server running on http://localhost:9292'
  server.start
end
