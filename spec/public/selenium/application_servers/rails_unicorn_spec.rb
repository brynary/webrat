require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")
require "webrat/selenium/application_servers/rails_unicorn"

RAILS_ROOT = "." unless defined?(RAILS_ROOT)


describe Webrat::Selenium::ApplicationServers::RailsUnicorn do
  include Webrat::Selenium::SilenceStream

  before do
    @server = Webrat::Selenium::ApplicationServers::RailsUnicorn.new
    # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
    @server.stub!(:system)
    @server.stub!(:at_exit)

    # Fake the top-level Rails object
    class Rails
      cattr_accessor :root
      cattr_accessor :version
    end

    Rails.root = RAILS_ROOT
    Rails.version = "3."
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

  describe "start command" do
    context "when run under Rails v2" do
      before do
        ::Rails.version = "2.x.x"
      end

      it "should invoke unicorn_rails" do
        @server.start_command.should == "cd '#{RAILS_ROOT}' && bundle exec unicorn_rails -D -p 3001 -E test"
      end
    end

    context "when run under Rails v3" do
      before do
        ::Rails.version = "3.x.x"
      end

      context "with the default configuration" do
        it "should invoke unicorn" do
          @server.start_command.should == "cd '#{RAILS_ROOT}' && bundle exec unicorn -D -p 3001 -E test"
        end
      end

      context "when configuration specifies a :unicorn_conf_file" do
        before do
          Webrat.configure do |conf|
            conf.unicorn_conf_file = "/foo/bar.rb"
          end
        end

        it "should invoke unicorn" do
          @server.start_command.should == "cd '#{RAILS_ROOT}' && bundle exec unicorn -D -p 3001 -E test -c /foo/bar.rb"
        end
      end
    end
  end
end
