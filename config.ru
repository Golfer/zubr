require './config/initialize'
require './environment'

Zubr::Base.run! if ENV['RACK_ENV'] != 'test'
