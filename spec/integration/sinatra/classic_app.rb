require "sinatra"

use_in_file_templates!

get "/" do
  erb :home
end

get "/go" do
  erb :go
end

get "/internal_redirect" do
  redirect "/"
end

get "/external_redirect" do
  redirect "http://google.com"
end

post "/go" do
  @user = params[:name]
  @email = params[:email]
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

<form>
  <label>
    Prefilled
    <input type="text" name="prefilled" value="text" />
  </label>
</form>

@@ go
<form method="post" action="/go">
  <div>
    <label for="name">Name</label>
    <input type="text" name="name" id="name">
  </div>
  <div>
    <label for="email">Email</label>
    <input type="text" name="email" id="email">
  </div>
  <input type="submit" value="Submit" />
</form>

@@ hello
<p>Hello, <%= @user %></p>
<p>Your email is: <%= @email %></p>
