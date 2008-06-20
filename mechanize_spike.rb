require "lib/webrat"
require "lib/webrat/mechanize"

include Webrat

sess = MechanizeSession.new
sess.visits "http://www.google.com/"
sess.fills_in "q", :with => "Webrat"
sess.clicks_button
sess.save_and_open_page