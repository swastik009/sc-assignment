## app/api/app_loader.rb
require 'json'
require 'webrick'
require_relative 'lib/client_loader'
require_relative 'lib/client_searcher'
require_relative 'app/api/api_controller'

class AppLoader
  def initialize(file_path)
    @clients, @keys = ClientLoader.load(file_path)
    @searcher = ClientSearcher.new(@clients)
    @api_controller = ApiController.new(@clients, @keys, @searcher)
  end

  def start_server(port = 9292)
    server = WEBrick::HTTPServer.new(Port: port)
    server.mount_proc '/' do |req, res|
      status, headers, body = @api_controller.route(req)
      res.status = status
      headers.each { |k, v| res[k] = v }
      res.body = body.join
    end
    trap('INT') { server.shutdown }
    puts "Server running on http://localhost:#{port}"
    server.start
  end
end
