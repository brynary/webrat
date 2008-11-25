module Webrat #:nodoc:
  def self.session_class #:nodoc:
    TestSession
  end
  
  class TestSession < Session #:nodoc:
    attr_accessor :response_body
    attr_writer :response_code
    
    def doc_root
      File.expand_path(File.join(".", "public"))
    end
    
    def response
      @response ||= Object.new
    end
    
    def response_code
      @response_code || 200
    end
    
    def get(url, data)
    end
    
    def post(url, data)
    end
    
    def put(url, data)
    end
    
    def delete(url, data)
    end
  end
end