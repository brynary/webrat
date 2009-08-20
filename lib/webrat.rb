require "rack"
require "nokogiri"

module Webrat
  # The common base class for all exceptions raised by Webrat.
  class WebratError < StandardError
  end
end

require "webrat/core"
