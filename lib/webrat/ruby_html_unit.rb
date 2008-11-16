$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RubyHtmlUnit
  Jars = Dir[File.dirname(__FILE__) + '/ruby_html_unit/htmlunit/*.jar']
end

if RUBY_PLATFORM =~ /java/
  require 'java'
  RubyHtmlUnit::Jars.each { |jar| require(jar) }
  
  module HtmlUnit
    include_package 'com.gargoylesoftware.htmlunit'
  end
  JavaString = java.lang.String
else
  raise "RubyHtmlUnit only works on JRuby at the moment."
end


Dir[File.join(File.dirname(__FILE__), "ruby_html_unit", "*.rb")].each do |file|
  require File.expand_path(file)
end


# Deal with the test server
if `uname`.chomp == "Darwin"
  TEST_SERVER_PORT = '3001'
  
  if `ps ax`.match(/^\s*(\d*).*-e test -p #{TEST_SERVER_PORT}/)
    puts "A test server was found running on port #{TEST_SERVER_PORT} (PID #{$1})"
  else
    puts "A test server was not found running (looking for -e test -p #{TEST_SERVER_PORT})"
    puts "Please start a new test server using the command below:"
    puts
    
    command_string = "ruby #{RAILS_ROOT}/script/server -e test -p #{TEST_SERVER_PORT}"
    
    puts command_string
    exit
  end
end