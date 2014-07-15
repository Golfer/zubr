#environment
require 'bundler'
require 'sinatra/base'
require 'rest_client'
require 'fileutils'
require 'open-uri'
require 'nokogiri'
require 'carrierwave'
require 'json'
require 'yaml'
require 'addressable/uri'

Bundler.require

# include our Application code
require File.join(File.dirname(__FILE__), 'zubr_base.rb')

Dir[File.dirname(__FILE__) + '/lib/parser/*_parser.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/app/uploaders/*.rb'].each {|file| require file }
