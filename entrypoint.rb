require_relative 'app/api/app_loader'

if __FILE__ == $0
  file_path = ARGV[0] || 'data/clients.json'
  loader = AppLoader.new(file_path)
  require 'webrick'
  server = WEBrick::HTTPServer.new(Port: 9292, DocumentRoot: File.expand_path('public', __dir__))

  # Serve Swagger UI at /
  server.mount '/', WEBrick::HTTPServlet::FileHandler, File.expand_path('public/swagger-ui/index.html', __dir__)

  # Serve swagger.json explicitly with correct Content-Type
  server.mount_proc '/swagger.json' do |req, res|
    res['Content-Type'] = 'application/json'
    res.body = File.read(File.expand_path('public/swagger.json', __dir__))
  end

  # API endpoints
  server.mount_proc '/api' do |req, res|
    status, headers, body = loader.api_controller.route(req)
    res.status = status
    headers.each { |k, v| res[k] = v }
    res.body = body.join
  end

  trap('INT') { server.shutdown }
  puts 'Server running on http://localhost:9292'
  server.start
end