module Webrat #:nodoc:
  def self.adapter_class #:nodoc:
    TestAdapter
  end

  class TestAdapter #:nodoc:
    attr_accessor :response_body
    attr_writer :response_code

    def initialize(*args)
    end

    def response
      @response ||= Object.new
    end

    def response_code
      @response_code || 200
    end

    def get(url, data, headers = nil)
    end

    def post(url, data, headers = nil)
    end

    def put(url, data, headers = nil)
    end

    def delete(url, data, headers = nil)
    end
  end
end
