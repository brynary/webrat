Dir[File.join(File.dirname(__FILE__), "core", "*.rb")].sort.each do |file|
  require File.expand_path(file)
end