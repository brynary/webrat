# Go to http://wiki.merbivore.com/pages/init-rb

# Specify a specific version of a dependency
# dependency "RedCloth", "> 3.0"

#  use_orm :none
use_test :rspec
use_template_engine :erb

Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper

  # cookie session store configuration
  c[:session_secret_key]  = 'adb9ea7a0e94b5513503f58623a393c5efe18851'  # required for cookie session store
  c[:session_id_key] = '_merb_session_id' # cookie session id key, defaults to "_session_id"
end

Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end

Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end
