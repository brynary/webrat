# it "should default to current url" do
# # current_page.stub!(:url => "/page")
#   response_body = <<-HTML
#     <form method="get">
#       <input type="submit" />
#     </form>
#   HTML
#   @page.stub!(:url => "/current")
#   webrat_session.should_receive(:get).with("/current", {})
#   click_button
# end
# 
# it "should follow fully qualified secure local links" do
#   response_body = <<-HTML
#     <a href="https://www.example.com/page/sub">Jump to sub page</a>
#   HTML
#   webrat_session.should_receive(:https!).with(true)
#   webrat_session.should_receive(:get).with("/page/sub", {})
#   click_link "Jump to sub page"
# end