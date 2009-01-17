class FakeModel
  def id
    nil
  end
end

class WebratController < ApplicationController

  def form
  end

  def submit
    render :text => "OK"
  end

  def internal_redirect
    redirect_to :submit
  end
  
  def external_redirect
    redirect_to "http://google.com"
  end

end