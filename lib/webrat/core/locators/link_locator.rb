class LinkLocator
  
  def initialize(scope, value)
    @scope = scope
    @value = value
  end
  
  def locate
    # TODO - Convert to using elements
    
    matching_links = link_elements.select do |link_element|
      matches_text?(link_element) ||
      matches_id?(link_element)
    end

    if matching_links.any?
      link_element = matching_links.min { |a, b| Webrat::XML.inner_text(a).length <=> Webrat::XML.inner_text(b).length }
      @scope.link_by_element(link_element)
    else
      nil
    end
  end
  
  def matches_text?(link)
    if @value.is_a?(Regexp)
      matcher = @value
    else
      matcher = /#{Regexp.escape(@value.to_s)}/i
    end

    replace_nbsp(Webrat::XML.inner_text(link)) =~ matcher ||
    replace_nbsp_ref(Webrat::XML.inner_html(link)) =~ matcher ||
    Webrat::XML.attribute(link, "title")=~ matcher
  end

  def matches_id?(link)
    if @value.is_a?(Regexp)
      (Webrat::XML.attribute(link, "id") =~ @value) ? true : false
    else
      (Webrat::XML.attribute(link, "id") == @value) ? true : false
    end
  end
  
  def link_elements
    Webrat::XML.css_search(@scope.dom, *Webrat::Link.css_search)
  end
  
  def replace_nbsp(str)
    str.gsub([0xA0].pack('U'), ' ')
  end

  def replace_nbsp_ref(str)
    str.gsub('&#xA0;',' ').gsub('&nbsp;', ' ')
  end
  
end