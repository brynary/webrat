require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require "webrat/sinatra"

class Sinatra::Application
  # Override this to prevent Sinatra from barfing on the options passed from RSpec
  def self.load_default_options_from_command_line!
  end
end

Sinatra::Application.default_options.merge!(
  :env          => :test,
  :run          => false,
  :raise_errors => true,
  :logging      => false
)