require 'sinatra/base'
require 'rest_client'
require 'fileutils'
require 'nokogiri'
require 'json'
require 'yaml'

Dir[File.dirname(__FILE__) + '/lib/parser/*_parser.rb'].each {|file| require file }

class Zubr < Sinatra::Base

	LOG_PATH = "#{settings.root}/log/#{settings.environment}.log"

	configure do
		set :server, 'webrick'
		set :partial_template_engine, :haml
		set :root, File.dirname(__FILE__)
	end

	configure do
		enable :logging
		file = File.new(LOG_PATH, 'a+')
		file.sync = true
		use Rack::CommonLogger, file
	end

	before { env['rack.logger'] = Logger.new(LOG_PATH) }

	get '/' do
		content_type :json
		{ message: 'Hello World!' }.to_json
	end

	get '/cookorama' do
		puts 'Run Cookorama Parser !!!'
		CookoramaParser.parse_page('http://cookorama.net/')
	end

	not_found do
		content_type :json
		halt 404, { error: 'URL not found' }.to_json
	end

end

Zubr.run! if ENV['RACK_ENV'] != 'test'



