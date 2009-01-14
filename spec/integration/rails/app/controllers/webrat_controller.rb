class WebratController < ApplicationController

  def form
  end

  def submit
    render :text => "OK <a href='/' id='link_id'>Test Link Text</a>"
  end

  def internal_redirect
    redirect_to :submit
  end
  
  def external_redirect
    redirect_to "http://google.com"
  end

end