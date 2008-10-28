# it "should default to current url" do
# # @session.current_page.stub!(:url).and_return("/page")
#   @session.response_body = <<-EOS
#     <form method="get">
#       <input type="submit" />
#     </form>
#   EOS
#   @page.stub!(:url).and_return("/current")
#   @session.should_receive(:get).with("/current", {})
#   @session.clicks_button
# end
# 
# it "should follow fully qualified secure local links" do
#   @session.response_body = <<-EOS
#     <a href="https://www.example.com/page/sub">Jump to sub page</a>
#   EOS
#   @session.should_receive(:https!).with(true)
#   @session.should_receive(:get).with("/page/sub", {})
#   @session.clicks_link "Jump to sub page"
# end