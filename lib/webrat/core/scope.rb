module Webrat
  class Scope
    
    def initialize(page, html)
      @page = page
      @html = html
    end
    
    def find_select_option(option_text)
      forms.each do |form|
        result = form.find_select_option(option_text)
        return result if result
      end
      
      nil
    end
    
    def find_link(text, selector = nil)
      matching_links = []
      
      links_within(selector).each do |possible_link|
        matching_links << possible_link if possible_link.matches_text?(text)
      end
      
      if matching_links.any?
        matching_links.sort_by { |l| l.text.length }.first
      else
        flunk("Could not find link with text #{text.inspect}")
      end
    end
    
    def find_field(id_or_name_or_label, *field_types)
      forms.each do |form|
        result = form.find_field(id_or_name_or_label, *field_types)
        return result if result
      end
      
      flunk("Could not find #{field_types.inspect}: #{id_or_name_or_label.inspect}")
    end
    
    def links_within(selector)
      (dom / selector / "a[@href]").map do |link_element|
        Link.new(@page, link_element)
      end
    end
    
    def forms
      return @forms if @forms
      
      @forms = (dom / "form").map do |form_element|
        Form.new(@page, form_element)
      end
    end
    
    def dom # :nodoc:
      return @dom if defined?(@dom) && @dom
      @dom = Hpricot(@html)
    end
    
  end
end