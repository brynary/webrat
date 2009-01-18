require "webrat"

# This is a temporary hack to support backwards compatibility
# with Merb 1.0.8 until it's updated to use the new Webrat.configure
# syntax

Webrat.configure do |config|
  config.mode = :merb
end