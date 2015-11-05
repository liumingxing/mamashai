require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

RAILS_ROOT = ::Rails.root.to_s
RAILS_ENV = ::Rails.env

module Mamashai
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'

    RAILS_DEFAULT_LOGGER = Logger.new("#{::Rails.root.to_s}/log/#{::Rails.env}.log", 2, 2000*1024*1024)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
    # Specify gems that this application depends on and have them installed with rake gems:install
    
    #config.gem 'paperclip'
    #config.gem "weibo"
    #config.gem 'rails_autolink'
    
    #config.gem 'uploadcolumn'
    #config.gem 'uploadcolumn', :lib => 'upload_column'
    # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
    # config.gem "sqlite3-ruby", :lib => "sqlite3"
    # config.gem "aws-s3", :lib => "aws/s3"
  
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
    # Skip frameworks you're not going to use. To use Rails without a database,
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
#    config.time_zone = 'UTC'

    config.active_record.default_timezone = :local
    config.time_zone = 'Beijing' 
  
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    config.middleware.delete 'Rack::Cache'   # 整页缓存，用不上
    config.middleware.delete 'Rack::Lock'    # 多线程加锁，多进程模式下无意义
#    config.middleware.delete 'Rack::Runtime' # 记录X-Runtime（方便客户端查看执行时间）
    config.middleware.delete 'ActionDispatch::RequestId' # 记录X-Request-Id（方便查看请求在群集中的哪台执行）
    config.middleware.delete 'ActionDispatch::RemoteIp'  # IP SpoofAttack
    config.middleware.delete 'ActionDispatch::Callbacks' # 在请求前后设置callback
    config.middleware.delete 'ActionDispatch::Head'      # 如果是HEAD请求，按照GET请求执行，但是不返回body
    config.middleware.delete 'Rack::ConditionalGet'      # HTTP客户端缓存才会使用
    config.middleware.delete 'Rack::ETag'    # HTTP客户端缓存才会使用
    config.middleware.delete 'ActionDispatch::BestStandardsSupport' 

  end

  RAILS_ROOT = ::Rails.root.to_s
  RAILS_ENV = ::Rails.env

  #ActionController::Base.cache_store = :file_store, "public/cache_fragment"
  
  require 'history'
  require 'exception_handler'
  require 'exception_loggable'
  #require 'state_machine'
  #require 'nokogiri'
  #require 'json'

  class ActiveRecord::Base
    #alias :named_scope :scope
    self.singleton_class.send(:alias_method, :named_scope, :scope)
  end

  require 'rmmseg'
  include RMMSeg

  RMMSeg::Dictionary.load_dictionaries

  def RMMSeg::segment(text)
    #s = `echo "#{text}" | rmmseg`   
    #s.split(' ')

    arr = []
    algor = RMMSeg::Algorithm.new(text)
    loop do
      tok = algor.next_token
      break if tok.nil?
      arr.push(tok.text.force_encoding("utf-8"))
    end
    arr
  end

class ActiveSupport::TimeWithZone
  def to_s(format = :default)
    if format == :db
      time.strftime("%Y-%m-%d %H:%M:%S")
    elsif formatter = ::Time::DATE_FORMATS[format]
      formatter.respond_to?(:call) ? formatter.call(self).to_s : strftime(formatter)
    else
      "#{time.strftime("%Y-%m-%d %H:%M:%S")} #{formatted_offset(false, 'UTC')}" # mimicking Ruby 1.9 Time#to_s format
    end
  end
end

end
