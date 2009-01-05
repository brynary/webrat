require "rubygems"
require "sinatra"
 
use_in_file_templates!
 
get "/" do
  erb :home
end
 
get "/go" do
  erb :go
end

get "/redirect" do
  redirect "/"
end
 
post "/go" do
  @user = params[:name]
  erb :hello
end
 
__END__

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <title>sinatra testing with webrat</title>
  <body>
    <%= yield %>
  </body>
</html>
 
@@ home
<p> visit <a href="/go">there</a></p>
 
@@ go
<form method="post" action="/go">
  <label for="name">Name</label>
  <input type="text" name="name" id="name">
  <input type="submit" value="Submit" />
</form>
 
@@ hello
<p>Hello, <%= @user %></p>