class LinkLocator
  
  def initialize(scope, value)
    @scope = scope
    @value = value
  end
  
  def locate
    matching_links = @scope.send(:links).select do |possible_link|
      possible_link.matches_text?(@value) || possible_link.matches_id?(@value)
    end

    if matching_links.any?
      matching_links.min { |a, b| a.text.length <=> b.text.length }
    else
      nil
    end
  end
  
end