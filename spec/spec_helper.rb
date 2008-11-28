require "rubygems"
require "spec"

# gem install redgreen for colored test output
begin require "redgreen" unless ENV['TM_CURRENT_LINE']; rescue LoadError; end

webrat_path = File.expand_path(File.dirname(__FILE__) + "/../lib/")
$LOAD_PATH.unshift(webrat_path) unless $LOAD_PATH.include?(webrat_path)

require "merb-core"
require "webrat/merb"

require "webrat"
require File.expand_path(File.dirname(__FILE__) + "/fakes/test_session")

Spec::Runner.configure do |config|
  include Webrat::Methods

  def with_html(html)
    raise "This doesn't look like HTML. Wrap it in a <html> tag" unless html =~ /^\s*<[^Hh>]*html/i
    webrat_session.response_body = html
  end
  
  def with_xml(xml)
    raise "This looks like HTML" if xml =~ /^\s*<[^Hh>]*html/i
    webrat_session.response_body = xml
  end
  
end

module Webrat
  @@previous_config = nil

  def self.cache_config_for_test
    @@previous_config = Webrat.configuration.clone
  end

  def self.reset_for_test
    @@configuration = @@previous_config if @@previous_config
  end
end