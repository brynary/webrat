require 'rubygems'
require "lib/webrat"
require "lib/webrat/selenium"
require 'selenium'

include Webrat

# To try it out:
#
# Install the required gem
#  > sudo gem install Selenium
#
# Fire up the Selenium proxy server
#  > selenium
#
# Run this script
#  > ruby selenium_spike.rb


@sel = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", "http://localhost", 15000)
@sel.start

sess = SeleniumSession.new(@sel)
sess.visits "http://www.google.com/"
sess.fills_in "q", :with => "Webrat"
sess.clicks_link 'Images'
sess.clicks_button 'Search'
sess.selects 'Small images', :from => 'imagesize'
sess.clicks_link 'Preferences'
sess.chooses 'Do not filter'
sess.checks 'Open search results in a new browser window'
sess.clicks_button
sess.save_and_open_page
@sel.stop
