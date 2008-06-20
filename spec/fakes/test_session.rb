module Webrat
  class TestSession < Session
    attr_accessor :response_body
    attr_writer :response_code
    
    def doc_root
      File.expand_path(File.join(".", "public"))
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