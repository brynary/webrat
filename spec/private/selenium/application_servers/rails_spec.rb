require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")
require "webrat/selenium/application_servers/rails"

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

describe Webrat::Selenium::ApplicationServers::Rails do
  include Webrat::Selenium::SilenceStream

  before do
    @server = Webrat::Selenium::ApplicationServers::Rails.new
    # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
    @server.stub!(:system)
    @server.stub!(:at_exit)
  end

  describe "boot" do
    it "should wait for the server to start on 0.0.0.0" do
      TCPSocket.should_receive(:wait_for_service_with_timeout).
        with(hash_including(:host => "0.0.0.0"))

      silence_stream(STDERR) do
        @server.boot
      end
    end
  end
end
