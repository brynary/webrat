module Webrat
  module Assertions
    
    def should_see(text_or_regexp)
      case text_or_regexp
      when Regexp
        return if scoped_html.match(text_or_regexp)
      else
        return if scoped_html.include?(text_or_regexp)
      end
      
      flunk("Should see #{text_or_regexp.inspect} but didn't")
    end

    def should_not_see(text_or_regexp)
      case text_or_regexp
      when Regexp
        return unless scoped_html.match(text_or_regexp)
      else
        return unless scoped_html.include?(text_or_regexp)
      end
      
      flunk("Should not see #{text_or_regexp.inspect} but did")
    end
    
  end
end