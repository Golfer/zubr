class TasteParser
	class << self
		URL_PATH = 'http://www.taste.com.au/'
		YAML_DIR_FILE = 'public/yaml_files'

		def parse_page(url)
			path_url = url.empty? ? URL_PATH : url
			p '-----------------------------------------'
			p path_url
			p '-----------------------------------------'
			extract_page_data = Nokogiri::HTML(open(path_url))
			path_parse_files = "#{YAML_DIR_FILE}/taste.com.au/recipes/collections/"
			Zubr::Base.create_directory(path_parse_files)
			p '**********************************************************************************'
			p path_parse_files
			p '**********************************************************************************'
			p extract_page_data
			p '**********************************************************************************'
			content_list = extract_page_data.css('div.module-content')

			p ' ==================================  ====== = = = = = = = = = = = = = = = ='
			p content_list
			p ' ==================================  ====== = = = = = = = = = = = = = = = ='
			p Zubr::Base::LOG_PATH
			p ' ==================================  ====== = = = = = = = = = = = = = = = ='
			#name_file = content_list.at_css('div#nav div#blog-menu h1').text

			#File.open("#{path_parse_files}/#{name_file.downcase.gsub(/\s/, '_')}.json", 'w') do |json_file|
			#	puts 'Start parse  CookoramaParser'
			#	json_file.write('[')
			#	add_coma = false
			#	topic = content_list.css('div .topic')
			#	topic.each do |item|
			#		topic_name = item.at('.title a').text
			#		topic_href = item.at('.title a')["href"]
			#		blockHash = { title: {name: topic_name, href: topic_href}}
			#		puts "Parse: #{blockHash}"
			#
			#		detail_block_parse = Nokogiri::HTML(open("#{topic_href}"))
			#		method_of_cooking = detail_block_parse.css('.content p.instructions').text
			#		blockHash.merge!(cooking: method_of_cooking )
			#		puts "Recept: #{blockHash}"
			#		sleep 2
			#
			#		string = add_coma ? ", #{blockHash.to_json}" : blockHash.to_json
			#		json_file.write(string)
			#		add_coma = true
			#	end
			#
			#
			#	pagination = content_list.css('div #pagination')
			#	pagination.each do |pagin|
			#		puts '<<< ====== PAGINATION ================ >>>'
			#		puts pagin
			#		puts '<<< ====== PAGINATION ================ >>>'
			#	end
			#
			#	json_file.write(']')
			#	puts 'finish parse  CookoramaParser'
			#end
		end

	end

end