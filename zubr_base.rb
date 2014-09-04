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
			Zubr::Base.create_directory(Zubr::YAML_DIR_FILE) unless File.exists?(Zubr::YAML_DIR_FILE)
			Zubr::Base.create_directory(Zubr::IMAGE_DIR_FILE) unless File.exists?(Zubr::IMAGE_DIR_FILE)
			Zubr::Base.create_directory(DIR_LOG) unless File.exists?(DIR_LOG)
		end

		class << self
			def create_directory(path)
				FileUtils::mkdir_p(path) unless File.exists?(path)
			end

			def save_into_yaml_file(path_to_file, file, options={})
				return false if file.nil?
				file = File.new("#{Zubr::YAML_DIR_FILE}/#{path_to_file}#{mask(file)}.yml", 'w')
				file.write(options.to_yaml)
				file.close
			end

			#for replase all specials chars
			def mask(param)
				param.gsub(/[^a-zA-Z0-9\-]/,'_').gsub(/(^_|_$)/, '').gsub('/','\/').squeeze('_')
			end

			#TODO save images
			def upload_image(img_link, file_name)
				p "Download image #{img_link}  start: #{Time.now.strftime('%m/%d/%Y %H:%M %p')} file: #{file_name}"
				#upload = RecipeUploader.new
				#upload.file = img_link
				#upload.image = img_link = Zubr::IMAGE_DIR_FILE + File.join(filename) #записали в бд путь до изображения
				#upload.thumb = params[:thumb] = Zubr::IMAGE_DIR_FILE + '/thumb_' + File.join(filename) #записали в бд путь до превью изображения
				#upload.save #загрузили - сохранили
			end
		end


		get '/' do
			logger.info "Root path #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			content_type :json
			{ message: 'go to Home page' }.to_json
		end

		get '/cookorama' do
			logger.info "Run Cookorama Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')} - #{Zubr::Base.root}"
			#Zubr::Base::CookoramaParser.parse('http://cookorama.net/uk/index/page1/')
			Zubr::Base::CookoramaParser.parse
		end

		get '/taste' do
			logger.info "Run Taste Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
			TasteParser.parse(params.blank? ? nil : params)
		end

		not_found do
			content_type :json
			halt 404, { error: 'URL not found' }.to_json
		end

		private
	end
end
