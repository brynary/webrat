RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.time_zone = 'UTC'
  config.action_controller.session = {
    :session_key => '_rails_app_session',
    :secret      => '81f33872c27349e86f1dc2cd6708995b9c26578e6e2d8992e567cd64d96e844343149f6e2f44bf178304141db9ce39e741e0e60699867c29c51c6d7ef7dc9556'
  }
end
