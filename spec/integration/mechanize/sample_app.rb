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

  get "/form" do
    <<-EOS
    <html>
      <form action="/form" method="post">
        <input type="hidden" name="_method" value="put" />
        <label for="email">Email:</label> <input type="text" id="email" name="email" /></label>
        <input type="submit" value="Add" />
      </form>
    </html>
    EOS
  end

  put "/form" do
    "Welcome #{params[:email]}"
  end
end
