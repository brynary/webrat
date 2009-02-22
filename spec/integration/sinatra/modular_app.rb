require "rubygems"
require "sinatra/base"

class MyModularApp < Sinatra::Default
  get "/" do
    "Hello World"
  end
end
