unless (RAILS_ENV =~ /^test/).nil? and RAILS_ENV != "selenium"
  require File.join(File.dirname(__FILE__), "lib", "webrat")
end
