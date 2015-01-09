class Zubr::Base::TasteParser
  def initialize
    logger.info "Initialize Zubr Taste Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
  end

  class << self
    URL_PATH = 'http://www.taste.com.au/recipes/collections/'

    def parse(params)
      path_to_parse = params.nil? ? URL_PATH : params['url']
      create_dir(path_to_parse.match(/http:\/\/(.*)/)[1].gsub('.html',''))
      extract_page_data = Nokogiri::HTML(open(path_to_parse))
      content_list = extract_page_data.css('.all-recipes')
      page_collections = content_list.css('.content-item .story-block')
      page_collections.each do |collection|
        collection_img  = collection.at('.thumbnail img')['src'] unless collection.at('.thumbnail img').blank?
        collection_size  = collection.at('.thumbnail span').text.gsub(' Recipes', '') unless collection.at('.thumbnail span').blank?
        collection_href = collection.at('.heading a')['href'] unless collection.at('.heading a').blank?
        collection_name = collection.at('.heading a').text unless collection.at('.heading a').blank?

        options = {
            collection_href_path: collection_href,
            collection_full_name: collection_name,
            collection_count_recipe: collection_size,
            collection_img_thumbs: collection_img,
            collection_settings_path: Zubr::Base.generate_correct_path(collection_href)
        }

        get_current_collection(options) unless options[:collection_href_path].nil?
      end
    end

    def get_current_collection(options)
      return nil if options.nil?
      p "Start parse collection #{options[:collection_full_name]}: #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"

      unless options[:collection_href_path].blank?
        collection_image_file = options[:collection_img_thumbs].match(/collections\/(.*)/)[1].gsub(' ','')
        Zubr::Base.upload_image(options[:collection_img_thumbs], options[:collection_settings_path], collection_image_file) unless options[:collection_img_thumbs].blank?

        extract_page_data = Nokogiri::HTML(open(options[:collection_href_path]))
        all_recipes = extract_page_data.css('.in-collections-all')
        link_collections = all_recipes.css('.module-controls .tab-set')
        all_set_collection = {}
        link_collections.css('li').each { |link| all_set_collection.merge!(Zubr::Base.mask(link.at('a').text.downcase).to_sym =>  link.at('a')['href']) }
        get_collection_all_recipes(options.merge!(current_collection_all_recipes_path: all_set_collection[:all_recipes])) unless all_set_collection[:all_recipes].nil?
      end
    end

    def get_collection_all_recipes(options)
      create_dir(options[:current_collection_all_recipes_path].match(/http:\/\/(.*)/)[1])
      page_data = Nokogiri::HTML(open(options[:current_collection_all_recipes_path]))
      pagination = get_list_pagination(page_data.css('.paging a'))
      pagination.each{ |key, path_link| p "Parse collection (#{options[:collection_full_name]}): page: #{path_link}"; get_page_recipe(path_link) }
    end

    def get_page_recipe(page_link)
      page_current_path = page_link.match(/http:\/\/(.*)/)[1]
      create_dir(page_current_path)
      page_data = Nokogiri::HTML(open(page_link))
      all_recipes_module = page_data.css('.module-content')

      recipes = all_recipes_module.css('.content-item .story-block')
      recipes.each do |recipe|
        recipe_options={}
        recipe_name = recipe.at('.heading a').text unless recipe.at('.heading a').blank?
        file_name = Zubr::Base.mask(recipe_name.downcase)
        recipe_options.merge!(recipe_name: recipe_name.nil? ? nil : recipe_name)
        recipe_href = recipe.at('.heading a')['href'] unless recipe.at('.heading a').blank?
        recipe_options.merge!(recipe_href: recipe_href.nil? ? nil : recipe_href)
        recipe_thumb  = recipe.at('img')['src'] unless recipe.at('img').blank?
        recipe_options.merge!(header_img: recipe_thumb.nil? ? nil : recipe_thumb)
        path_to_current_recipe = "#{page_current_path}/#{file_name}"
        recipe_options.merge!(path_to_current_recipe: path_to_current_recipe.nil? ? nil : path_to_current_recipe)

        create_dir(path_to_current_recipe)
        Zubr::Base.upload_image(recipe_thumb, path_to_current_recipe, "#{file_name}.jpeg") unless recipe_thumb.blank? #TODO need to refactored
        get_current_recipe(recipe_options) unless recipe_options[:recipe_href].blank?
      end
    end

    #TODO needs to refactored
    def get_current_recipe(options)
      return false if options[:recipe_href].nil?
      Zubr::Base.save_into_yaml_file("#{options[:path_to_current_recipe]}/", 'setting_options', options)
      recipe_options = {}
      extract_recipe_data = Nokogiri::HTML(open(options[:recipe_href]))
      data_page = extract_recipe_data.css('.group-2 .group-content')
      quote_left = data_page.css('.recipe-detail .quote-left').text
      recipe_options.merge!(quote_left: quote_left.nil? ? nil : quote_left)
      prep_time = data_page.css('.content-item .prepTime em').text
      recipe_options.merge!(prep_time: prep_time.nil? ? nil : prep_time)
      cook_time = data_page.css('.content-item .cookTime em').text
      recipe_options.merge!(cook_time: cook_time.nil? ? nil : cook_time)
      ingredient_count = data_page.css('.content-item .ingredientCount em').text
      recipe_options.merge!(ingredient_count: ingredient_count.nil? ? nil : ingredient_count)
      difficulty_title = data_page.css('.content-item .difficultyTitle em').text
      recipe_options.merge!(difficulty_title: difficulty_title.nil? ? nil : difficulty_title)
      servings = data_page.css('.content-item .servings em').text
      recipe_options.merge!(servings: servings.nil? ? nil : servings)
      rating = data_page.css('.content-item .rating .star-level').text
      recipe_options.merge!(rating: rating.nil? ? nil : rating)
      recipe_img_large  = data_page.at('.recipe-detail .print-thumb')['src']
      recipe_options.merge!(recipe_img_large: recipe_img_large.nil? ? nil : recipe_img_large)

      #TODO
      source_author = data_page.css('.source-author')

      all_ingridients = []
      ingredients_table = data_page.css('.ingredients-nutrition .ingredients-tab-content')
      ingredients_table.css('li').each do |ingredient|
        all_ingridients.push(ingredient.text.split.join(" ").to_s) if ingredient
      end
      recipe_options.merge!(ingridients: all_ingridients.nil? ? nil : all_ingridients)

      #TODO
      nutritions_table = data_page.css('.ingredients-nutrition .nutrition-tab-content')

      all_instruction_preparations_step = []

      data_page.css('.method-tab-content li').each do |method_step|
        all_instruction_preparations_step.push(Zubr::Base.mask(method_step.css('.step').text.downcase).to_sym => method_step.css('.description').text.to_s) if method_step
      end

      recipe_options.merge!(instruction_preparations_step: all_instruction_preparations_step.nil? ? nil : all_instruction_preparations_step)

      Zubr::Base.save_into_yaml_file("#{options[:path_to_current_recipe]}/", Zubr::Base.mask(options[:recipe_name]), recipe_options)
      Zubr::Base.upload_image(recipe_img_large, options[:path_to_current_recipe], Zubr::Base.mask(options[:recipe_name]), true ) unless recipe_img_large.blank?

      sleep(3)
    end

    private

    def get_list_pagination(pagination_list)
      result = {}
      last_page =  pagination_list[pagination_list.length-2] #TODO need refactored
      first_el = pagination_list.first.text
      end_el = last_page.text
      (first_el..end_el).map{ |i| result.merge!( "page_#{i}".to_sym => "#{pagination_list.first['href']}/#{i}" ) }
      result
    end

    def create_dir(path)
      Zubr::Base.create_directory("#{Zubr::YAML_DIR_FILE}/#{path}")
      Zubr::Base.create_directory("#{Zubr::IMAGE_DIR_FILE}/#{path}")
    end
  end
end
