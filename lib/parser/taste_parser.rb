class Zubr::Base::TasteParser
	def initialize
		logger.info "Initialize Zubr Taste Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
	end

	class << self
		URL_PATH = 'http://www.taste.com.au/recipes/collections/'


		def pparse(url = URL_PATH)
			extract_page_data = Nokogiri::HTML(open(url))
			content_list = extract_page_data.css('div#content')

			pagination = content_list.css('div #pagination')
			if pagination.blank?
				parse_page(url)
			else
				parse_page(url)
				pagination.css('li').each do |item|
					if item['class'] == 'active'
						@current_page_number = item.at('span').text.to_i
					end
					unless item.at('a').blank?
						unless (@current_page_number + 1) != item.at('a').text.to_i
							@path_parse_files = item.at('a')['href'].match(/http:\/\/(.*)/)[1]
							create_dir
							parse(item.at('a')['href'])
						end
					end
				end
			end
		end

		def parse(params)
			p "Start Parse #{params.nil? ? "Params Default URL: #{URL_PATH}" : params}"
			path_to_parse = params.nil? ? URL_PATH : params['url']
			@path_parse_files = path_to_parse.match(/http:\/\/(.*)/)[1].gsub('.html','')
			create_dir
			extract_page_data = Nokogiri::HTML(open(path_to_parse))
			content_list = extract_page_data.css('.all-recipes')
			page_collections = content_list.css('.content-item .story-block')
			page_collections.each do |collection|
				collection_img  = collection.at('.thumbnail img')['src'] unless collection.at('.thumbnail img').blank?
				collection_size  = collection.at('.thumbnail span').text.gsub(' Recipes', '') unless collection.at('.thumbnail span').blank?
				collection_href = collection.at('.heading a')['href'] unless collection.at('.heading a').blank?
				collection_name = collection.at('.heading a').text unless collection.at('.heading a').blank?
				#p [collection_size, collection_href]
				if collection_href
					p "Start parse collection: #{collection_name}"
					parse_collections(collection_href)
					break
				end
			end



			#url = Addressable::URI.parse(path)
			#p '------------------------------'
			#p url
			#p Zubr::Base.mask(url.host)
			#p Zubr::Base.mask(url.path)
			#p '------------------------------'

			#link_in = path_to_parse.match(/www.taste.com.au\/(.*)/)[1]
			#params_in = $1.gsub(/[^a-zA-Z0-9\-]/,"_").gsub('-', '_').squeeze("_").chomp('_')

			#extract_page_data = Nokogiri::HTML(open(path_to_parse))
			#content_list = extract_page_data.css('div.module-content')


			#need_parse = content_list.css('div.content-item')
			#pagination = content_list.css('div.content-item.paging')
			#p '**************************'
			#p need_parse
			#p '**************************'

			#p CGI::parse(request.query_string)
			#case parse_params
			#	when 'collections'
			#		parse_collections(url)
			#	else
			#		p "Another args ++++++ #{@path_parse}"
			#end
			#extract_page_data = Nokogiri::HTML(open(url))
			#content_list = extract_page_data.css('.module-content')

			#pagination = content_list.css('.paging .page-numbers')
			#if pagination.blank?
			#	parse_page(url)
			#else
			#	parse_page(url)
			#	pagination.css('a').each do |item|
			#		if item['class'] == 'on selected'
			#			@current_page_number = item.text.to_i unless item.at('a').blank?
			#			break
			#		end
			#		unless item.blank?
			#			unless (@current_page_number + 1) != item.text.to_i
			#				@path_parse_files = item['href'].match(/http:\/\/(.*)/)[1]
			#				create_dir
			#				parse(item['href'])
			#			end
			#		end
			#	end
			#end

		end

		private

		def create_dir
			p "Create Dirs when does not exists: #{@path_parse_files}"
			Zubr::Base.create_directory("#{Zubr::YAML_DIR_FILE}/#{@path_parse_files}")
			Zubr::Base.create_directory("#{Zubr::IMAGE_DIR_FILE}/#{@path_parse_files}")
		end


		def parse_collections(path)
			p "Start Collection Parse: #{path}"
			extract_page_data = Nokogiri::HTML(open(path))
			our_recipes = extract_page_data.css('.in-collections-all')
			link_collections = our_recipes.css('.module-controls .tab-set')
			all_set_collection = {}
			link_collections.css('li').each do |link_collection|
				all_set_collection.merge!(Zubr::Base.mask(link_collection.at('a').text.downcase).to_sym =>  link_collection.at('a')['href'])
			end
			all_set_collection.each do |key, value|
				case key
					when :all_recipes
						parse_all_recipes(value)
					else
						#TODO
						p [key, value]
				end
			end

		end

		def parse_all_recipes(path)
			p "Start Parse All recipes: #{path}"
			extract_all_recipes = Nokogiri::HTML(open(path))
			all_recipes_module = extract_all_recipes.css('.module-content')
			all_recipes = all_recipes_module.css('.content-item .story-block')
			all_recipes.each do |recipe|
				options={}
				recipe_name = recipe.at('.heading a').text unless recipe.at('.heading a').blank?
				file_name = Zubr::Base.mask(recipe_name.downcase)
				options.merge!(recipe_name: recipe_name.nil? ? nil : recipe_name)
				recipe_href = recipe.at('.heading a')['href'] unless recipe.at('.heading a').blank?
				options.merge!(recipe_href: recipe_href.nil? ? nil : recipe_href)
				recipe_img  = recipe.at('img')['src'] unless recipe.at('img').blank?
				options.merge!(header_img: recipe_img.nil? ? nil : recipe_img['src'])
				Zubr::Base.upload_image(recipe_img['src'], file_name) unless recipe_img.blank?
				#Zubr::Base.upload_image(recipe.at('img')['src'], file_name) unless unless recipe.at('img').blank?
				#TODO write method parse current recipe
				#p [recipe_href, file_name , recipe_img] #todo
				if recipe_href
					p "Write to file #{file_name}"
					parse_recipe(recipe_href)
					#options.merge!(parse_recipe(recipe_href))
				end
			end
			#TODO Pagination recursed method!!!!!
			pagination_block = all_recipes_module.css('.paging')
			#if pagination_block
			#	p 'Start parse  pagination when this pagination exists'
			#	p pagination_block
			#	p 'Start parse  pagination when this pagination exists'
			#end
			#Zubr::Base.save_into_yaml_file(@path_parse_files, file_name, options) unless file_name.blank?
			sleep 1

		end

		def parse_recipe(url)
			return false if url.nil?

			p '*******parse_recipe********************'
			p [url]
			p '*******parse_recipe********************'

			recipe_options = {}
			extract_recipe_data = Nokogiri::HTML(open(url))
			all_ingridients = []
			#ingridients_table = extract_recipe_data.css('#view-topic .ingredients tr')
			#ingridients_table.each do |ingredient|
			#	all_ingridients.push(ingredient.at('td:first .dot a').text => ingredient.at('td:nth-child(2)').text.to_s) unless ingredient['class'] != 'ingredient'
			#end
			#recipe_options.merge!(ingridients: all_ingridients.nil? ? nil : all_ingridients)
			#
			#instructions = extract_recipe_data.css('#view-topic').at('.content .instructions').text
			#recipe_options.merge!(instructions: instructions.nil? ? nil : instructions)
			#
			#instruction_preparations = extract_recipe_data.css('#view-topic').at('.content').after('.instructions').text
			#recipe_options.merge!(instruction_preparations: instruction_preparations.nil? ? nil : instruction_preparations)
			#
			recipe_options
		end
	end
end
