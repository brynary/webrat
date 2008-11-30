module Webrat
  
  class Element
    
    def self.load_all(session, dom)
      Webrat::XML.xpath_search(dom, xpath_search).map do |element| 
        load(session, element)
      end
    end
    
    def self.load(session, element)
      session.elements[Webrat::XML.xpath_to(element)] ||= self.new(session, element)
    end
    
    def initialize(session, element)
      @session  = session
      @element  = element
    end
    
  end
  
end