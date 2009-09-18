class FakeModel
  def id
    nil
  end
end

class WebratController < ApplicationController

  def form
  end

  def submit
    render :text => "OK <a href='/' id='link_id'>Test Link Text</a>"
  end

  def internal_redirect
    redirect_to submit_path
  end

  def infinite_redirect
    redirect_to infinite_redirect_path
  end

  def external_redirect
    redirect_to "http://google.com"
  end

  def host_redirect
    redirect_to submit_url
  end

  def before_redirect_form
  end

  def redirect_to_show_params
    redirect_to show_params_path(:custom_param => "123")
  end

  def show_params
    render :text => params.to_json
  end

  def within
  end

end
