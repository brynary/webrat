ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => "webrat" do |webrat|
    webrat.submit             "/submit",            :action => "submit"
    webrat.internal_redirect  "/internal_redirect", :action => "internal_redirect"
    webrat.external_redirect  "/external_redirect", :action => "external_redirect"

    webrat.root :action => "form"
  end
end
