Dir[File.join(File.dirname(__FILE__), "core", "*.rb")].each do |file|
  require File.expand_path(file)
end