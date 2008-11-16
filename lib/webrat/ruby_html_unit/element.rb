module RubyHtmlUnit

  class Element
    def initialize(element, page)
      @html_unit_element = element
      @page = page
    end

    def elem_type
      @html_unit_element.node_name
    end
    
    def id_attribute
      @html_unit_element.id_attribute
    end
    
    def matches_text?(text)
      @html_unit_element.as_text =~ text_as_regexp(text)
    end
    
    def matches_attribute?(attribute, text)
      @html_unit_element.get_attribute(attribute) =~ text_as_regexp(text)
    end
    
    def ancestors
      current_element = self
      [].tap do |ancs|
        while current_element.parent && current_element.elem_type != 'html'
          ancs << current_element
          current_element = current_element.parent
        end
      end
    end
    
    def label_matches?(label_text)
      ancestors.each do |anc|
        return true if anc.elem_type == 'label' && anc.matches_text?(label_text)
      end
      
      if id_attribute.blank?
        return nil
      else
        label_tag = @page.elements_by_xpath("//label[@for='#{id_attribute}']").first
        return label_tag if label_tag && label_tag.matches_text?(label_text)
      end
    end
    
    def click
      @html_unit_element.click
    end
    
    def fill_in_with(value)
      clear
      type_string(value)
    end
    
    def clear
      case @html_unit_element.getTagName
        when 'textarea' then @html_unit_element.setText('')
        when 'input'    then @html_unit_element.setValueAttribute('')
      end
    end
    
    def select(option_text)
      @html_unit_element.getOptions.select { |e| e.asText =~ text_as_regexp(option_text) }.each do |option|
        option.click
        #@container.update_page(option.click)
      end
    end
    
    def set(value = true)
      @html_unit_element.setChecked(value)
      #value ? @html_unit_element.click : @html_unit_element.setChecked(value)
    end
    
    def includes_option?(option_text)
      !!@html_unit_element.getByXPath("//option").detect {|opt| opt.as_text =~ text_as_regexp(option_text) }
    end
    
    def to_s
      @html_unit_element.as_text
    end
    
    def hidden?
      !!ancestors.detect { |elem| elem.style =~ /display\s*:[\s'"]*none/ }
    end

    def visible?
      !hidden?
    end

    def parent
      @html_unit_element.respond_to?(:parent_node) ? Element.new(@html_unit_element.parent_node, @page) : nil
    end

    def class_name
      @html_unit_element.class_attribute
    end
    
    def method_missing(name, *args)
      return @html_unit_element.send("#{name}_attribute") if @html_unit_element.respond_to?("#{name}_attribute")
      super
    end
    
  protected
    def type_string(value)
      last_page = nil
      JavaString.new(value.to_java_bytes, @html_unit_element.getPage.getPageEncoding).toCharArray.each do |char|
        last_page = @html_unit_element.type(char)
      end
      last_page
    end
    
    def text_as_regexp(text)
      Regexp.new(Regexp.escape(text), true)
    end
  end

end