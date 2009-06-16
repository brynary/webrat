ActionController::Routing::Routes.draw do |map|
  map.resource 'links', :only => [:show]
  map.resource 'buttons', :only => [:show, :create]
  map.resource 'fields', :only => [:show]
  map.with_options :controller => "webrat" do |webrat|
    webrat.submit             "/submit",            :action => "submit"
    webrat.internal_redirect  "/internal_redirect", :action => "internal_redirect"
    webrat.external_redirect  "/external_redirect", :action => "external_redirect"
    webrat.infinite_redirect  "/infinite_redirect", :action => "infinite_redirect"
    webrat.host_redirect      "/host_redirect",     :action => "host_redirect"

    webrat.before_redirect_form     "/before_redirect_form",    :action => "before_redirect_form"
    webrat.redirect_to_show_params  "/redirect_to_show_params", :action => "redirect_to_show_params"
    webrat.show_params              "/show_params",             :action => "show_params"

    webrat.root :action => "form"
  end
end
