module Webrat
  # The common base class for all exceptions raised by Webrat.
  class WebratError < StandardError
  end
end

require "rack"
require "nokogiri"
require "webrat/core/xml/nokogiri"
require "webrat/core"
