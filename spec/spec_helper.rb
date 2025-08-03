# spec/spec_helper.rb
require 'rspec'

require 'pry'
require_relative '../lib/client_loader'
require_relative '../lib/client'
require_relative '../lib/client_searcher'


RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
