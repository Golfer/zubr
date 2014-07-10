module Zubr
	YAML_DIR_FILE = 'public/yaml_files'
	IMAGE_DIR_FILE = 'public/image_files'

	class Base < Sinatra::Base
		DIR_LOG = "#{settings.root}/log/"
		LOG_PATH = "#{settings.root}/log/#{settings.environment}.log"

		configure do
			set :server, 'webrick'
			set :root, File.dirname(__FILE__)
			enable :logging
			file = File.new(LOG_PATH, 'a+')
			file.sync = true
			use Rack::CommonLogger, file
		end

		before do
			env['rack.logger'] = Logger.new(LOG_PATH)

			#Create public folder images, yaml, log files
			create_directory(Zubr::YAML_DIR_FILE) unless File.exists?(Zubr::YAML_DIR_FILE)
			create_directory(Zubr::IMAGE_DIR_FILE) unless File.exists?(Zubr::IMAGE_DIR_FILE)
			create_directory(DIR_LOG) unless File.exists?(DIR_LOG)

		end

		class << self
			def download_image(img)
				logger.info "Download image #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			end
		end


		get '/' do
			logger.info "Root path #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			content_type :json
			{ message: 'go to Home page' }.to_json
		end

		get '/cookorama' do
			logger.info "Run Cookorama Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			Zubr::CookoramaParser.parse('http://cookorama.net/')
		end

		get '/taste-most-recent' do
			logger.info "Run Taste Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			TasteParser.parse_page('http://www.taste.com.au/recipes/collections/15+minute+meals?sort=recent&ref=collections,15-minute-meals')
		end

		not_found do
			content_type :json
			halt 404, { error: 'URL not found' }.to_json
		end

		private

			def create_directory(path)
				FileUtils::mkdir_p(path) unless File.exists?(path)
			end
	end
end
