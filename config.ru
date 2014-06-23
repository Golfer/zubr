require 'config/initialize'
require './environment'

ZubrBase.run! if ENV['RACK_ENV'] != 'test'