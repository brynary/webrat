Gem::Specification.new do |s|
  s.name = %q{webrat}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bryan Helmkamp", "Seth Fitzsimmons"]
  s.date = %q{2008-10-13}
  s.description = %q{When comparing Webrat with an in-browser testing solution like Watir or Selenium, the primary consideration should be how much JavaScript the application uses. In-browser testing is currently the only way to test JS, and that may make it a requirement for your project. If JavaScript is not central to your application, Webrat is a simpler, effective solution that will let you run your tests much faster and more frequently.  Initial development was sponsored by [EastMedia](http://www.eastmedia.com).  Synopsis --------}
  s.email = ["bryan@brynary.com", "seth@mojodna.net"]
  s.extra_rdoc_files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.txt", "TODO.txt"]
  s.files = ["History.txt", "MIT-LICENSE.txt", "Manifest.txt", "README.txt", "Rakefile", "TODO.txt", "init.rb", "install.rb", "lib/webrat.rb", "lib/webrat/core.rb", "lib/webrat/core/assertions.rb", "lib/webrat/core/field.rb", "lib/webrat/core/flunk.rb", "lib/webrat/core/form.rb", "lib/webrat/core/label.rb", "lib/webrat/core/link.rb", "lib/webrat/core/logging.rb", "lib/webrat/core/scope.rb", "lib/webrat/core/select_option.rb", "lib/webrat/core/session.rb", "lib/webrat/mechanize.rb", "lib/webrat/mechanize/mechanize_session.rb", "lib/webrat/rails.rb", "lib/webrat/rails/rails_session.rb", "lib/webrat/rails/redirect_actions.rb", "lib/webrat/rails/session.rb", "lib/webrat/selenium.rb", "lib/webrat/selenium/selenium_session.rb", "mechanize_spike.rb", "selenium_spike.rb", "spec/api/attaches_file_spec.rb", "spec/api/checks_spec.rb", "spec/api/chooses_spec.rb", "spec/api/clicks_button_spec.rb", "spec/api/clicks_link_spec.rb", "spec/api/fills_in_spec.rb", "spec/api/reloads_spec.rb", "spec/api/save_and_open_spec.rb", "spec/api/selects_spec.rb", "spec/api/should_not_see_spec.rb", "spec/api/should_see_spec.rb", "spec/api/visits_spec.rb", "spec/api/within_spec.rb", "spec/fakes/test_session.rb", "spec/integration/rails_spec.rb", "spec/rcov.opts", "spec/spec.opts", "spec/spec_helper.rb", "spec/webrat/core/logging_spec.rb", "spec/webrat/core/session_spec.rb", "spec/webrat/rails/rails_session_spec.rb", "webrat.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{- [Code on GitHub](http://github.com/brynary/webrat)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{webrat}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Ruby Acceptance Testing for Web applications}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
