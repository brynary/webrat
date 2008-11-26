if (RAILS_ENV =~ /^test/) || RAILS_ENV == "selenium"
  require "webrat/rails"
end
