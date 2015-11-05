Mamashai::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.perform_caching             = true
  config.cache_template_loading            = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  #ActionMailer::Base.delivery_method = :sendmail
  ActionMailer::Base.delivery_method = :smtp 
  #ActionMailer::Base.default_charset = 'utf-8'
  #ActionMailer::Base.delivery_method = :async_sendmail
  ActionMailer::Base.sendmail_settings = { 
    :location       => '/usr/sbin/sendmail', 
    :arguments      => '-i -t'  
  }

  #ActionMailer::Base.delivery_method = :async_smtp
  ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'mamashai.com',
    :authentication => :login,
    :user_name => 'cc.mamashai@gmail.com',
    :password => 'mamashai66',
    :tls => true
  }


  # Adds :async_smtp and :async_sendmail delivery methods
  # to perform email deliveries asynchronously
  module AsynchronousMailer
    %w(smtp sendmail).each do |type|
      define_method("perform_delivery_async_#{type}") do |mail|
        Thread.start do
          send "perform_delivery_#{type}", mail
        end      
      end
    end
  end

  ActionMailer::Base.send :include, AsynchronousMailer


  WEB_ROOT = 'http://mamashai.com'
  WEB_DOMAIN = 'mamashai.com'
  MAP_BAR_KEY = 'aCW9cItqL78mbRAzaBAuLhNqbXT8NeMzMHTrEeJyNzZhOYf4Mzf6El==@zz8T7h8AzfRbJzzNhbEOzNzAbzaJYb=LA8H8fABNu8l8JNzzHJzE=HfNmzz=zHBbzJh/09='



  # Use a different cache store in production
  config.cache_store = :dalli_store, "www.mamashai.com" ,{ :namespace => 'mamashai', :compress => true }

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!
end
