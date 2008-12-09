# Supports using the matchers in controller, helper, and view specs if you're
# using rspec-rails. Just add a require statement to spec/spec_helper.rb or env.rb:
# 
#   require 'webrat/rspec-rails'
#
require "webrat/core/matchers"

Spec::Runner.configure do |config|
  # rspec should support :type => [:controller, :helper, :view] - but until it does ...
  config.include(Webrat::Matchers, :type => :controller)
  config.include(Webrat::Matchers, :type => :helper)
  config.include(Webrat::Matchers, :type => :view)
end