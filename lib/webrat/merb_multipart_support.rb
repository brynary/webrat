module Webrat

  # These methods are copied from merb-core/two-oh.rb which defines new
  # multipart_post and multipart_put methods for Merb::Test::MultipartRequestHelper.
  # We can't require two-oh.rb because it alters Merb's own behavior, causing
  # failing specs in Merb when Webrat is required.
  module MerbMultipartSupport
    def multipart_request(path, params = {}, env = {})
      multipart = Merb::Test::MultipartRequestHelper::Post.new(params)
      body, head = multipart.to_multipart
      env["CONTENT_TYPE"] = head
      env["CONTENT_LENGTH"] = body.size
      env[:input] = StringIO.new(body)
      request(path, env)
    end

    def multipart_post(path, params = {}, env = {})
      env[:method] = "POST"
      multipart_request(path, params, env)
    end

    def multipart_put(path, params = {}, env = {}, &block)
      env[:method] = "PUT"
      multipart_request(path, params, env)
    end
  end
end