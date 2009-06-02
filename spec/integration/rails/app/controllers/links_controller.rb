class LinksController < ApplicationController
  def show
    if params[:value]
      render :text => "Link:#{params[:value]}"
    end
  end
end
