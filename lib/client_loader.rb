
require 'oj'
require_relative 'client'

##
# ClientLoader loads client data from a JSON file and returns client objects and their keys.
#
# @example Load clients from file
#   clients, keys = ClientLoader.load('data/clients.json')
class ClientLoader
  ##
  # Loads client records from a JSON file and returns client objects and unique keys.
  #
  # @param path [String] The path to the JSON file.
  # @return [Array<Array<Client>, Array<String, Symbol>>] Array of clients and array of unique keys.
  # @raise [Errno::ENOENT] If the file does not exist (rescued internally).
  # @raise [Oj::ParseError] If the JSON is invalid (rescued internally).
  def self.load(path)
    data = Oj.strict_load(File.read(path))
    clients = data.map { |record| Client.new(record) }
    [clients, clients.flat_map(&:keys).uniq]
  rescue Errno::ENOENT
    puts "File not found: #{path}"
    [[], []]
  rescue Oj::ParseError => e
    puts "Failed to load clients: #{e.message}"
    [[], []]
  end
end
