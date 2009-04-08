class Testing < Application

  def show_form
    render
  end

  def submit_form
  end

  def internal_redirect
    redirect "/"
  end

  def external_redirect
    redirect "http://google.com"
  end

end
