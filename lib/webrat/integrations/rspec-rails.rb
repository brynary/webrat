# Supports using the matchers in controller, helper, and view specs if you're
# using rspec-rails. Just add a require statement to spec/spec_helper.rb or env.rb:
#
#   require 'webrat/integrations/rspec-rails'
#
require "nokogiri"
require "webrat/core/matchers"

# If Rspec 2 is being used, avoid deprecation warning
configure_method = defined?(RSpec) ? RSpec.method(:configure) : Spec::Runner.method(:configure)
configure_method.call do |config|
  config.include(Webrat::Matchers, :type => [:controller, :helper, :view])
end
