class Zubr::Base::CookoramaParser
  def initialize
    logger.info "Initialize Zubr Cookorama Parser #{Time.now.strftime('%m/%d/%Y %H:%M %p')}"
  end

  class << self
    URL_PATH = 'http://cookorama.net/en/'
    def parse(url = URL_PATH)
      p "Start Parse #{url}"
      @path_parse_files = url.match(/http:\/\/(.*)/)[1].gsub('.html','')
      create_dir
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

    private

    def create_dir
      p "Create Dirs when does not exists: #{@path_parse_files}"
      Zubr::Base.create_directory("#{Zubr::YAML_DIR_FILE}/#{@path_parse_files}")
      Zubr::Base.create_directory("#{Zubr::IMAGE_DIR_FILE}/#{@path_parse_files}")
    end

    def parse_page(parse_url)
      extract_page_data = Nokogiri::HTML(open(parse_url))
      content_list = extract_page_data.css('div#content')

      topic = content_list.css('div .topic')
      topic.each do |item|
        options={}
        topic_name = item.at('.title a').text unless item.at('.title a').blank?
        options.merge!(recipe_name: topic_name.nil? ? nil : topic_name)
        topic_href = item.at('.title a')['href'] unless item.at('.title a').blank?
        options.merge!(recipe_href: topic_href.nil? ? nil : topic_href)
        file_name = topic_name.downcase.gsub(' ', '_').gsub('"', '')
        header_img = item.at('.topic-recipe-img img')
        options.merge!(header_image: header_img.nil? ? nil : header_img['src'])
        #Zubr::Base.upload_image(header_img['src'], file_name) unless header_img.blank?

        p "Write to file #{file_name}"

        speed_cooking = item.css('.topic-recipe-content ul').at('li:first-child a').text unless item.css('.topic-recipe-content ul').at('li:first-child a').blank?
        options.merge!(speed_cooking: speed_cooking.nil? ? nil : speed_cooking)

        date_create = item.css('.voting-border').at('.date').text unless item.css('.voting-border').at('.date').blank?
        options.merge!(date_create: date_create.nil? ? nil : date_create)

        top_tags = []
        item.css('.top-tags li').each do |top_tag|
          top_tags.push(top_tag.at('a').text)
        end
        options.merge!(top_tags: top_tags.nil? ? nil : top_tags)

        tags = []
        item.css('.tags li').each do |tag|
          tags.push(tag.at('a').text)
        end
        options.merge!(tags: tags.nil? ? nil : tags)

        unless topic_href.blank?
          options.merge!(parse_recipe(topic_href))
        end

        Zubr::Base.save_into_yaml_file(@path_parse_files, file_name, options) unless file_name.blank?
        sleep rand(2)
      end
    end

      def parse_recipe(url)
        return false if url.nil?
        recipe_options = {}
        extract_recipe_data = Nokogiri::HTML(open(url))

        all_ingridients = []
        ingridients_table = extract_recipe_data.css('#view-topic .ingredients tr')
        ingridients_table.each do |ingredient|
          all_ingridients.push(ingredient.at('td:first .dot a').text => ingredient.at('td:nth-child(2)').text.to_s) unless ingredient['class'] != 'ingredient'
        end
        recipe_options.merge!(ingridients: all_ingridients.nil? ? nil : all_ingridients)

        instructions = extract_recipe_data.css('#view-topic').at('.content .instructions').text
        recipe_options.merge!(instructions: instructions.nil? ? nil : instructions)

        instruction_preparations = extract_recipe_data.css('#view-topic').at('.content').after('.instructions').text
        recipe_options.merge!(instruction_preparations: instruction_preparations.nil? ? nil : instruction_preparations)

        recipe_options
      end
  end
end
