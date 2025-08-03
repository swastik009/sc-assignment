# app/api/app_loader.rb
require 'json'
require 'webrick'
require_relative 'api_controller'
require_relative '../../lib/client_loader'
require_relative '../../lib/client_searcher'

class AppLoader
  def initialize(file_path)
    @clients, @keys = ClientLoader.load(file_path)
    @searcher = ClientSearcher.new(@clients)
    @api_controller = ApiController.new(@clients, @keys, @searcher)
  end

  def api_controller
    @api_controller
  end
end
