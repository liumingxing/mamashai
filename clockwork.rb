ENV["RAILS_ENV"]='production'
require File.expand_path('../config/boot', __FILE__)
require File.expand_path('../config/environment', __FILE__)

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 5
    config[:logger] = Logger.new(File.join(Rails.root,'log/clockwork.log'))
    config[:max_threads] = 15
    config[:thread] = true
  end

  error_handler do |e|
    # ExceptionNotifier.notify_exception(e)
  end

  def self.wrapper(message)
    logger = ->(mes) do
      `echo #{Time.now.to_s} #{mes} >> #{File.join(Rails.root,'log/clockwork.log')}`
    end
    begin
      start_time = Time.now
      logger.call message + '开始'
      yield
      end_time = Time.now
      duration = ((end_time - start_time)/60).round(1)
      logger.call message + "结束，用时#{duration}分钟"
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end

  every(1.hours, 'stub.job') do
    puts 'clockwork is running.'
  end

  every(1.hours, 'midnight.job', :at => '01:00') do
    Clockwork.wrapper('半屏广告自动更新上下线状态') do
      CalendarAdv.synchronize_status
    end
  end
end