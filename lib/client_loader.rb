require 'oj'
require_relative 'client'

class ClientLoader
  def self.load(path)
    data = Oj.strict_load(File.read(path))
    clients = data.map { |record| Client.new(record) }
    [clients, clients.flat_map(&:keys).uniq]
  rescue Errno::ENOENT
    puts "File not found: #{path}"
    []
  rescue Oj::ParseError => e
    puts "Failed to load clients: #{e.message}"
    []
  end
end
