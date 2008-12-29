ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => "webrat" do |webrat|
    webrat.submit "/submit",  :action => "submit"
    webrat.root               :action => "form"
  end
end
