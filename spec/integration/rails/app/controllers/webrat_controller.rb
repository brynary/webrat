class WebratController < ApplicationController

  def form
  end

  def submit
    render :text => "OK"
  end

  def redirect
    redirect_to :submit
  end

end