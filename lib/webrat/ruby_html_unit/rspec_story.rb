class Spec::Story::Runner::ScenarioRunner
  def initialize
    @listeners = []
  end
end

module RubyHtmlUnit
  
  class RspecStory
    include ::Spec::Matchers
    include ::Spec::Rails::Matchers
    
    def current_session
      @current_session ||= Session.new
    end
    
    def method_missing(name, *args)
      if current_session.respond_to?(name)
        current_session.send(name, *args)
      else
        super
      end
    end
  end
  
end