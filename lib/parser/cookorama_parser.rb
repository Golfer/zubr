class Zubr::Base::CookoramaParser
	def initialize
		logger.info "Initialize Zubr Cookorama Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
	end

	class << self
		URL_PATH = 'http://cookorama.net/en/'

		def parse_recipe(url=nil)
			path_url = url.empty? ? URL_PATH : url
			puts '=------------'
			puts [path_url]
			puts '=------------'
		end

		def parse(url = URL_PATH)
			p "Start Parse #{url}"
			extract_page_data = Nokogiri::HTML(open(url))
			path_parse_files = url.match(/http:\/\/(.*)/)[1].gsub('.html','')
			p "Create Dirs when does not exists: #{path_parse_files}"
			Zubr::Base.create_directory("#{Zubr::YAML_DIR_FILE}/#{path_parse_files}")
			Zubr::Base.create_directory("#{Zubr::IMAGE_DIR_FILE}/#{path_parse_files}")

			content_list = extract_page_data.css('div#content')
			topic = content_list.css('div .topic')

			topic.each do |item|
				topic_name = item.at('.title a').text
				file_name = topic_name.downcase.gsub(' ', '_').gsub('"', '')
				image = item.at('.topic-recipe-img img')
				Zubr::Base.upload_image(image['src'], file_name) unless image.blank?

				p "Start Write to file #{file_name}"
				#topic_recipe_content = item.css('.content .topic-recipe .topic-recipe-content')
				#topic_tags = item.css('.tags')
				#topic_tags.each do |tag|
				#	p 'Tags: ------- '
				#	p tag.text
				#	p 'Tags: ------- '
				#end

				#voting = item.css('voting-border')
				#date_create_recipe = voting.at('.date').text
				#p date_create_recipe

				#speed_cooking = item.at('.content .topic-recipe .topic-recipe-content').text

				#p topic_recipe_content
				#File.open("#{path_parse_files}/#{file_name}.yaml", 'w') do |yaml_file|
				#	yaml_file.write({ 'tags' => 'tag1 tag2 tag3'.split(/,\s|,/) }.to_yaml)
					#yaml_file.write({ 'topic_recipe_content' => topic_recipe_content }.to_yaml)
					#yaml_file.write({ 'date_create_recipe' => date_create_recipe }.to_yaml)
					#yaml_file.close
				#end
			end

			#name_file = content_list.at_css('div#nav div#blog-menu h1').text

			#File.open("#{path_parse_files}/#{name_file.downcase.gsub(/\s/, '_')}.json", 'w') do |json_file|
			#	puts 'Start parse  CookoramaParser'
			#	json_file.write('[')
			#	add_coma = false
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
