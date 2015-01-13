ENV['RACK_ENV'] = 'test'

require_relative '../environment'

require File.join(File.dirname(__FILE__), '..', 'zubr_base.rb')

require 'rubygems'
require 'rack/test'
require 'rspec'

Dir.glob('../lib/**/*.rb').each { |r| require_relative r }

RSpec.configure do |config|
  config.color = true
  config.include Rack::Test::Methods
end

# Add an app method for RSpec
def app
  Zubr::Base
end
