if RAILS_ENV == "test" || RAILS_ENV == "selenium"
  require File.join(File.dirname(__FILE__), "lib", "webrat")
end
