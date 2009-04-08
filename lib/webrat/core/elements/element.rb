module Webrat

  class Element # :nodoc:

    def self.load_all(session, dom)
      Webrat::XML.xpath_search(dom, xpath_search).map do |element|
        load(session, element)
      end
    end

    def self.load(session, element)
      return nil if element.nil?
      session.elements[Webrat::XML.xpath_to(element)] ||= self.new(session, element)
    end

    attr_reader :element

    def initialize(session, element)
      @session  = session
      @element  = element
    end

    def path
      Webrat::XML.xpath_to(@element)
    end

    def inspect
      "#<#{self.class} @element=#{element.inspect}>"
    end

  end

end
