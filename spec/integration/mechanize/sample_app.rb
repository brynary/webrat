require "rubygems"
require "sinatra/base"

class SampleApp < Sinatra::Default
  get "/" do
    "Hello World"
  end

  get "/internal_redirect" do
    redirect URI.join(request.url, "redirected").to_s
  end

  get "/external_redirect" do
    redirect "http://example.tst/"
  end

  get "/redirected" do
    "Redirected"
  end
end
