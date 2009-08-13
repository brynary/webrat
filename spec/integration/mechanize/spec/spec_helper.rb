require "rubygems"
require "spec"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../../../../lib"
require "webrat"

Webrat.configure do |config|
  config.mode = :mechanize
end

Spec::Runner.configure do |config|
  config.include Webrat::Methods
  config.include Webrat::Matchers

  config.before :suite do
    if File.exists?("rack.pid")
      Process.kill("TERM", File.read("rack.pid").to_i)
    end

    system "rackup --daemonize --pid rack.pid config.ru"
  end

  config.after :suite do
    Process.kill("TERM", File.read("rack.pid").to_i)
  end
end

