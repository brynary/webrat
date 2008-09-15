module RubyHtmlUnit
  
  class Page
    SAVED_PAGE_DIR = File.expand_path('.')
    
    def initialize(html_unit_page)
      @html_unit_page = html_unit_page
    end
    
    def body
      @html_unit_page.getWebResponse.getContentAsString || ''
    end
    alias_method :html_document, :body
  
    def find_link(text)
      matching_links = elements_by_tag_name('a').select{|e| e.matches_text?(text)}
      
      if matching_links.any?
        matching_links.sort_by { |l| l.to_s.length }.first
      else
        flunk("Could not find link with text #{text.inspect}")
      end
    end
    
    def find_button(text = nil)
      buttons = []
      field_type_xpaths = %w( //button //input[@type='submit'] //input[@type='reset'] //input[@type='image'] //input[@type='button'] )
      field_type_xpaths.each do |xpath_expr|
        buttons += elements_by_xpath(xpath_expr)
      end
      
      return buttons.first if text.nil?
      
      matching_buttons = buttons.select{|b| b.matches_attribute?('value', text) }
      
      if matching_buttons.any?
        matching_buttons.sort_by { |b| b.to_s.length }.first
      else
        flunk("Could not find button with text #{text.inspect}")
      end
    end
    
    def find_field(id_or_name_or_label, field_type)
      field_type_xpaths = case field_type
                          when :text      then %w( //input[@type='text'] //input[@type='hidden'] //textarea )
                          when :select    then %w( //select )
                          when :radio     then %w( //input[@type='radio'] )
                          when :checkbox  then %w( //input[@type='checkbox'] )
                          end
      
      field_type_xpaths.each do |xpath_expr|
        elements_by_xpath(xpath_expr).each do |possible_field|
          return possible_field if  possible_field.id_attribute  == id_or_name_or_label ||
                                    possible_field.name          == id_or_name_or_label ||
                                    possible_field.label_matches?(id_or_name_or_label)
        end
      end

      flunk("Could not find #{field_type_xpaths.inspect}: #{id_or_name_or_label.inspect}")
    end
    
    def find_select_list_with_option(option_text, id_or_name_or_label = nil)
      if id_or_name_or_label
        select_tag = find_field(id_or_name_or_label, :select)
        return select_tag if select_tag && select_tag.includes_option?(option_text)
      else
        elements_by_xpath("//select").each do |sel|
          if sel.includes_option?(option_text)
            return sel
          end
        end
      end
      nil
    end
        
    def elements_by_tag_name(tag_name)
      node_list = @html_unit_page.getElementsByTagName(tag_name)
      list_len = node_list.length
      
      [].tap do |array|
        0.upto(list_len-1) { |i| array << Element.new(node_list.item(i), self)}
      end
    end
    
    def elements_by_xpath(xpath_expression)
      @html_unit_page.getByXPath(xpath_expression).to_a.map{ |e| Element.new(e, self) }
    end
    
    def save_and_open
      return unless File.exist?(SAVED_PAGE_DIR)
      
      filename = "#{SAVED_PAGE_DIR}/webrat-#{Time.now.to_i}.html"
      
      File.open(filename, "w") do |f|
        f.write rewrite_css_and_image_references(body)
      end
      
      open_in_browser(filename)
    end
    
    def rewrite_css_and_image_references(response_html) # :nodoc
      response_html.gsub(%r<"/(stylesheets|images)>, Session.rewrite_url('"/\1'))
    end
    
    def open_in_browser(path) # :nodoc
      `open #{path}`
    end
    
    def flunk(message)
      raise message
    end
  end
  
end