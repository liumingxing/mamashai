Mamashai::Application.configure do
	# Settings specified here will take precedence over those in config/environment.rb

	# In the development environment your application's code is reloaded on
	# every request.  This slows down response time but is perfect for development
	# since you don't have to restart the webserver when you make code changes.
	config.cache_classes = false

	# Log error messages when you accidentally call methods on nil.
	config.whiny_nils = true

	# Show full error reports and disable caching
	config.consider_all_requests_local = true
	#config.action_view.debug_rjs                         = true
	config.perform_caching             = false

	config.active_support.deprecation = :log

	# Don't care if the mailer can't send
	config.action_mailer.raise_delivery_errors = false

	WEB_ROOT = 'http://localhost:3000'
	WEB_DOMAIN = 'localhost:3000'

	MAP_BAR_KEY = 'aCW9cItqL7...'

	# Redirect image and css files http requrest to FILE_ROOT server
	DEV_CONF_FILE = "#{::Rails.root.to_s}/config/dev.conf"
	if File.exist? DEV_CONF_FILE
	  eval(File.open(DEV_CONF_FILE,"r").read)
	end
	file_root ||= "http://www.mamashai.com"

	#config.gem 'rack-rewrite', '~> 0.2.1'
	#require 'rack-rewrite'

	config.cache_store = :mem_cache_store, "127.0.0.1"


	#config.middleware.insert_before(::Rack::Lock, ::Rack::Rewrite) do
	#  r302 %r{^#{WEB_ROOT}/images/(.*)}, "#{file_root}/images/$1"
	#  r302 %r{^#{WEB_ROOT}/upload/(.*)}, "#{file_root}/upload/$1"
	#  r302 %r{^#{WEB_ROOT}/stylesheets/(.*)}, "#{file_root}/stylesheets/$1"
	#  r302 %r{^/images/(.*)}, "#{file_root}/images/$1"
	#  r302 %r{^/upload/(.*)}, "#{file_root}/upload/$1"
	#  r302 %r{^/stylesheets/(.*)}, "#{file_root}/stylesheets/$1"
	#end
end
