# it "should default to current url" do
# # @session.current_page.stubs(:url).returns("/page")
#   @session.response_body = <<-EOS
#     <form method="get">
#       <input type="submit" />
#     </form>
#   EOS
#   @page.stubs(:url).returns("/current")
#   @session.expects(:get).with("/current", {})
#   @session.clicks_button
# end
# 
# it "should follow fully qualified secure local links" do
#   @session.response_body = <<-EOS
#     <a href="https://www.example.com/page/sub">Jump to sub page</a>
#   EOS
#   @session.expects(:https!).with(true)
#   @session.expects(:get).with("/page/sub", {})
#   @session.clicks_link "Jump to sub page"
# end