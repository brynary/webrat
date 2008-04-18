Dir[File.join(File.dirname(__FILE__), "webrat", "*.rb")].each do |file|
  require File.expand_path(file)
end

module Webrat
  VERSION = '0.2.1'
  def self.root
    defined?(RAILS_ROOT) ? RAILS_ROOT : Merb.root
  end
end

if defined?(Merb)
  require File.join(File.dirname(__FILE__), "boot_merb.rb")
else
  require File.join(File.dirname(__FILE__), "boot_rails.rb")
end
