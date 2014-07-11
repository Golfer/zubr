require './config/initialize'
require './environment'

run Zubr::Base if ENV['RACK_ENV'] != 'test'
