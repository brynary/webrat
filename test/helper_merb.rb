require 'merb-core'
require 'merb_stories'
module Merb
  module Test
    class RspecStory
      include Merb::Test::ControllerHelper
      include Merb::Test::RouteHelper
      include Merb::Test::ViewHelper
      def flunk(message)
        raise message
      end  
    end
 end
end
