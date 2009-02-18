require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "action_controller"
require "action_controller/integration"
require "webrat/selenium"

RAILS_ROOT = "/"


describe Webrat, "Selenium" do
  describe "start_app_server" do
    after(:each) { Webrat.configuration.application_framework = :rails }
    describe "ruby on rails" do
      it "should start the app server with correct config options" do
        pid_file = "file"
        Webrat.should_receive(:prepare_pid_file).with("#{RAILS_ROOT}/tmp/pids","mongrel_selenium.pid").and_return pid_file
        Webrat.should_receive(:system).with("mongrel_rails start -d --chdir='#{RAILS_ROOT}' --port=#{Webrat.configuration.application_port} --environment=#{Webrat.configuration.application_environment} --pid #{pid_file} &")
        TCPSocket.should_receive(:wait_for_service).with(:host => Webrat.configuration.application_address, :port => Webrat.configuration.application_port.to_i)
        Webrat.start_app_server
      end
    end
    describe "merb" do
      it "should start the app server with correct config options" do
        Webrat.configuration.application_framework = :merb
        Webrat.should_receive(:system).with("merb -d -p #{Webrat.configuration.application_port} -e #{Webrat.configuration.application_environment}")
        TCPSocket.should_receive(:wait_for_service).with(:host => Webrat.configuration.application_address, :port => Webrat.configuration.application_port.to_i)
        Webrat.start_app_server
      end
    end
    describe "sinatra" do
      it "should start the app server with correct config options" do
        rackup_file = File.expand_path(Dir.pwd + '/config.ru')
        Webrat.configuration.application_framework = :sinatra
        Webrat.should_receive(:fork)
#        Kernel.should_receive(:exec).with(['rackup', rackup_file, '-p', Webrat.configuration.application_port])
        TCPSocket.should_receive(:wait_for_service).with(:host => Webrat.configuration.application_address, :port => Webrat.configuration.application_port.to_i)
        Webrat.start_app_server
        FileUtils.rm_f 'rack.pid'
      end
    end
  end
  describe "stop_app_server" do
    after(:each) { Webrat.configuration.application_framework = :rails }
    describe "ruby on rails" do
      it "should stop the app server with correct config options" do
        pid_file = RAILS_ROOT+'/tmp/pids/mongrel_selenium.pid'
        Webrat.should_receive(:system).with("mongrel_rails stop -c #{RAILS_ROOT} --pid #{pid_file}")
        Webrat.stop_app_server
      end
    end
    describe "merb" do
      it "should stop the app server with correct config options" do
        Webrat.configuration.application_framework = :merb
        File.should_receive(:read).with('log/merb.3001.pid').and_return('666')
        Webrat.should_receive(:system).with("kill -9 666")
        Webrat.stop_app_server
      end
    end
    describe "sinatra" do
      it "should stop the app server with correct config options" do
        Webrat.configuration.application_framework = :sinatra
        File.should_receive(:read).with('rack.pid').and_return('666')
        Webrat.should_receive(:system).with("kill -9 666")
        Webrat.stop_app_server
        FileUtils.rm_f 'rack.pid'
      end
    end
  end

  it 'prepare_pid_file' do
    File.should_receive(:expand_path).with('path').and_return('full_path')
    FileUtils.should_receive(:mkdir_p).with 'full_path'
    File.should_receive(:expand_path).with('path/name')
    Webrat.prepare_pid_file 'path', 'name'
  end

  describe "start_selenium_server" do
    it "should not start the local selenium server if the selenium_server_address is set" do
      Webrat.configuration.selenium_server_address = 'foo address'
      ::Selenium::RemoteControl::RemoteControl.should_not_receive(:new)
      TCPSocket.should_receive(:wait_for_service).with(:host => Webrat.configuration.selenium_server_address, :port => Webrat.configuration.selenium_server_port)
      Webrat.start_selenium_server
    end

    it "should start the local selenium server if the selenium_server_address is set" do
      remote_control = mock "selenium remote control"
      ::Selenium::RemoteControl::RemoteControl.should_receive(:new).with("0.0.0.0", Webrat.configuration.selenium_server_port, 5).and_return remote_control
      remote_control.should_receive(:jar_file=).with(/selenium-server\.jar/)
      remote_control.should_receive(:start).with(:background => true)
      TCPSocket.should_receive(:wait_for_service).with(:host => "0.0.0.0", :port => Webrat.configuration.selenium_server_port)
      Webrat.start_selenium_server
    end
  end

  describe "stop_selenium_server" do

    it "should not attempt to stop the server if the selenium_server_address is set" do
      Webrat.configuration.selenium_server_address = 'foo address'
      ::Selenium::RemoteControl::RemoteControl.should_not_receive(:new)
      Webrat.stop_selenium_server
    end

    it "should stop the local server is the selenium_server_address is nil" do
      remote_control = mock "selenium remote control"
      ::Selenium::RemoteControl::RemoteControl.should_receive(:new).with("0.0.0.0", Webrat.configuration.selenium_server_port, 5).and_return remote_control
      remote_control.should_receive(:stop)
      Webrat.stop_selenium_server
    end
  end
end
