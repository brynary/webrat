require "rubygems"
require "sinatra/base"

class MyModularApp < Sinatra::Default
  get "/" do
    "Hello World"
  end

  get "/redirect_absolute_url" do
    redirect URI.join(request.url, "foo").to_s
  end

  get "/foo" do
    "spam"
  end
end
