class CookoramaParser
	class << self
		YAML_DIR_FILE = 'public/yaml_files'
		URL_PATH = 'http://cookorama.net/en/'

		def parse_recipe(url=nil)
			path_url = url.empty? ? URL_PATH : url
			puts '=------------'
			puts [path_url]
			puts '=------------'
		end

		def parse_page(url)
			path_url = url.empty? ? URL_PATH : url
			extract_page_data = Nokogiri::HTML(open(path_url))
			path_parse_files = "#{YAML_DIR_FILE}/cookorama.net/uk/new/"

			content_list = extract_page_data.css('div#content')
			name_file = content_list.at_css('div#nav div#blog-menu h1').text

			FileUtils::mkdir_p(path_parse_files) unless File.exists?(path_parse_files)
			File.open("#{path_parse_files}/#{name_file.downcase.gsub(/\s/, '_')}.json", 'w') do |json_file|
				puts 'Start parse  CookoramaParser'
				json_file.write('[')
				add_coma = false
				topic = content_list.css('div .topic')
				topic.each do |item|
					topic_name = item.at('.title a').text
					topic_href = item.at('.title a')["href"]
					blockHash = { title: {name: topic_name, href: topic_href}}
					puts "Parse: #{blockHash}"

					detail_block_parse = Nokogiri::HTML(open("#{topic_href}"))
					method_of_cooking = detail_block_parse.css('.content p.instructions').text
					blockHash.merge!(cooking: method_of_cooking )
					puts "Recept: #{blockHash}"
					sleep 2

					string = add_coma ? ", #{blockHash.to_json}" : blockHash.to_json
					json_file.write(string)
					add_coma = true
				end


				pagination = content_list.css('div #pagination')
				pagination.each do |pagin|
					puts '<<< ====== PAGINATION ================ >>>'
					puts pagin
					puts '<<< ====== PAGINATION ================ >>>'
				end

				json_file.write(']')
				puts 'finish parse  CookoramaParser'
			end
		end

		def write_to_file
			create_path('file/test/')
			file_name = 'test.yml'

			d = YAML::load_file(file_name) #Load
			d['content']['session'] = 2 #Modify
			File.open("#{path}/#{file_name}", 'w') {|f| f.write d.to_yaml } #Store
		end

		def create_path(path)
			FileUtils::mkdir_p(path) unless File.exists?(path)
		end

		def save_into_yaml_file(file_name, options=nil)
			return false if file_name.nil?
			FileUtils::mkdir_p YAML_DIR_FILE unless File.exists? YAML_DIR_FILE
			file = File.new("#{YAML_DIR_FILE}/#{file_name.downcase.gsub(/\s/, '_')}.yml", 'w')
			file.write({ 'options' => [1,2,3,4,5] }.to_yaml)
			file.close
		end

	end

end
