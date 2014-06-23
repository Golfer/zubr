require 'sinatra/base'
require 'rest_client'
require 'fileutils'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'yaml'


Dir[File.dirname(__FILE__) + '/lib/parser/*_parser.rb'].each {|file| require file }

class ZubrBase < Sinatra::Base

	configure :production, :development do
		enable :logging
	end

	DIR_LOG = "#{settings.root}/log/"
	LOG_PATH = "#{settings.root}/log/#{settings.environment}.log"

	Dir.mkdir(DIR_LOG) unless File.exist?(DIR_LOG)

	class << self
		def create_directory(path)
			Dir.mkdir(path) unless File.exists?(path)
		end

		def download_image(img)
			logger.info "Download image #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
		end
	end

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
		logger.info "Root Path Zubr Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
		content_type :json
		{ message: '!!! -- >Home Page@!@!' }.to_json
	end

	get '/cookorama' do
		logger.info "Run Cookorama Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
		CookoramaParser.parse_page('http://cookorama.net/')
	end

	get '/taste-most-recent' do
		logger.info "Run Taste Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
		TasteParser.parse_page('http://www.taste.com.au/recipes/collections/15+minute+meals?sort=recent&ref=collections,15-minute-meals')
	end

	not_found do
		content_type :json
		halt 404, { error: 'URL not found' }.to_json
	end
end

ZubrBase.run! if ENV['RACK_ENV'] != 'test'
