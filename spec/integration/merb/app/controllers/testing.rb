class Testing < Application

  def show_form
    render
  end

  def upload
    case request.method
    when :get then render
    when :post then
      uploaded_file = params[:uploaded_file]
      render [uploaded_file[:filename], uploaded_file[:tempfile].class.name].inspect
    end
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
