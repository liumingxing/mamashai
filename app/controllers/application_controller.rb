require File.join(::Rails.root.to_s,'lib/helpers')
require 'score'

class ApplicationController < ActionController::Base
  #include Memorylogic

  helper :all
  
  before_filter :check_cookies
  before_filter :deal_ad_keywords
  before_filter :check_blacknames
  before_filter :visit_count
  # before_filter :check_mms_user_login
    
  def check_blacknames
      black_ips = Rails.cache.fetch("blacknames", :expires_in=>10.minutes){
        Blackname.all().collect{|b| b.ip if b.ip}
      }
      if black_ips.include?(request.env["HTTP_X_REAL_IP"]||request.env["REMOTE_ADDR"])
        render :text => "visit denied by server" and return false;
      end

      return true;
  end
  ######################## function filters ##########################\
  
  def check_cookies
    unless session[:uid] 
      if cookies[:uid]
        user = User.find_by_id(cookies[:uid])
        if user and cookies[:uuid] and cookies[:uuid] == MamashaiTools::TextUtil.md5(user.password)
          session[:uid] = user.id.to_s
          #user.update_attributes(:last_login_at=>Time.now) if user.last_login_at.blank? or user.last_login_at.to_date < Date.today
          UserInfo.set_info(user.id, {:last_login_at=>Time.new})
        end
      end
    end
  end
  
  def enable_cookies(user)
    uid = user.id.to_s
    uuid = MamashaiTools::TextUtil.md5(user.password)
    
    #应付诡异问题　2011-10-14 lmx
    to = 6.months.from_now
    def to.to_s
      weekday = %w(Sun Mon Tue Wed Thu Fri Sat)
      mon = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)    
      "#{weekday[self.wday]}, #{self.month}-#{mon[self.month-1]}-#{self.year} #{self.hour}:#{self.min}:#{self.sec} GMT"
    end
    def to.strftime(arg)
      self.to_s
    end
    cookies[:uid] = {:domain => WEB_DOMAIN ,:value => uid, :path => '/', :expires => to }
    cookies[:uuid] = {:domain => WEB_DOMAIN ,:value => uuid, :path => '/', :expires => to }
  end
  
  def disable_cookies_and_session
    session[:uid] = nil
    to = -1.days.from_now
    def to.to_s
      weekday = %w(Sun Mon Tue Wed Thu Fri Sat)
      mon = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)    
      "#{weekday[self.wday]}, #{self.month}-#{mon[self.month-1]}-#{self.year} #{self.hour}:#{self.min}:#{self.sec} GMT"
    end
    def to.strftime(arg)
      self.to_s
    end
    cookies[:uid] = {:domain => WEB_DOMAIN ,:value => '', :path => '/', :expires => to }
    cookies[:uuid] = {:domain => WEB_DOMAIN ,:value => '', :path => '/', :expires => to }
    session[:uid] = nil
  end
  
  def deal_ad_keywords
    if params[:ad_keyword].present?
      session[:ad_keyword] = params[:ad_keyword] 
      cookies[:ad_keyword] = {:domain => WEB_DOMAIN ,:value => params[:ad_keyword], :path => '/', :expires => 6.months.from_now }
      KeywordSignup.update_all(["hits_count=hits_count+1"],["id=?",params[:ad_keyword]]) rescue nil
    else
      if params[:controller] == 'event' and params[:action].to_s.index('stick')
        session[:ad_keyword] = '121'
        cookies[:ad_keyword] = {:domain => WEB_DOMAIN ,:value => '121', :path => '/', :expires => 6.months.from_now }
        KeywordSignup.update_all(["hits_count=hits_count+1"],["id=?",'121']) rescue nil
        HttpRefer.create(:link=>'/event/namestick',:http_refer=>request.referer) unless request.referer.to_s.index('mamashai.com')
      end
      if params[:controller] == 'baby_books' and params[:action] == 'show' and params[:id] == '18'
        session[:ad_keyword] = '122'
        cookies[:ad_keyword] = {:domain => WEB_DOMAIN ,:value => '122', :path => '/', :expires => 6.months.from_now }
        KeywordSignup.update_all(["hits_count=hits_count+1"],["id=?",'122']) rescue nil
      end
    end
  end
  
  def count_ad_keywords
    if cookies[:ad_keyword].present? or session[:ad_keyword].present?
      keyword_id = session[:ad_keyword] if session[:ad_keyword].present?
      keyword_id = cookies[:ad_keyword] if cookies[:ad_keyword].present?
      keyword = KeywordSignup.find_by_id(keyword_id)
      if keyword.present?
        KeywordSignup.update_all(["signups_count=signups_count+1"],["id=?",keyword.id])
        today = Date.today
        day_keyword = DayKeywordSignup.find_by_day_and_keyword_signup_id(today,keyword.id)
        if day_keyword
          DayKeywordSignup.update_all(["signups_count=signups_count+1"],["id=?",day_keyword.id])
        else
          DayKeywordSignup.create(:keyword_signup_id=>keyword.id,:name=>keyword.name,:day=>today,:signups_count=>1)
        end
        session[:ad_keyword] = nil
        cookies[:ad_keyword] = {:domain => WEB_DOMAIN ,:value => '', :path => '/', :expires => -1.days.from_now }
      end
    end
  end
  
  def visit_count
    begin
      #return if ['Yahoo! Slurp China'].include?(request.env['HTTP_USER_AGENT'])
      for word in %w(bot spider jiankongbao slurp wget)
        return if request.env['HTTP_USER_AGENT'].to_s.downcase.include?(word)
      end
      Tongji.create(:ip=>request.env["HTTP_X_REAL_IP"]||request.env["REMOTE_ADDR"], :agent=>request.env['HTTP_USER_AGENT'], :url=>request.env['REQUEST_URI'][0, 200], :refer=>request.env['HTTP_REFERER'])
    rescue
    end
  end
  
  ##################### check user filters  #######################
  
  def need_login_user 
    @user = User.find(:first, :conditions=>["id=?", session[:uid]], :include=>%w(user_kids)) unless @user 
    unless @user
      session[:origin_url] = request.env["REQUEST_URI"]
      redirect_to :controller=>'account' , :action=>'login',:id=>nil and return false
    end
    if @user and @user.tp==-2
      disable_cookies_and_session
      redirect_to :controller=>'account' , :action=>'login',:id=>nil,:error=>'user_locked' and return false
    end
  end

  def check_mms_user_login
    if session[:mms_user].nil?
      redirect_to :controller => 'mms/login', :action => 'login'
    end
  end
  
  def need_login_angle
    unless @user.is_can_into_angle?
      redirect_to :controller=>'account' , :action=>'login',:id=>nil and return false
    end
  end
  
  def ajax_need_login_user 
    @user = User.find_by_id(session[:uid]) unless @user 
    unless @user
      render :action=>'please_login' and return false
    end
  end
  
  def need_login_name_user 
    if @user && @user.org_profile_id.blank? && @user.gender.blank?
      redirect_to :controller=>'account',:action=>'wizard_info',:id=>@user.id and return false
    end
    if @user && @user.org_profile_id.present? && @user.org_profile.content.blank?
      redirect_to :controller=>'account',:action=>'wizard_org_info',:id=>@user.id and return false
    end
  end
  
  def get_login_user 
    @user = User.find(:first, :conditions=>["id=?", session[:uid]], :include=>%w(user_kids)) unless @user 
  end
  
  def get_follow_user_ids
    @follow_user_ids = @user.follow_user_ids if @user
  end
  
  def get_user_join_events
    @join_events = Event.find_user_join_events(@user) if @user
  end
  
  def need_admin_login_user
    @user = User.find_by_id(session[:uid]) unless @user
    unless (@user and @user.is_admin)
      redirect_to :controller=>'account',:action=>'login' and return false
    end
  end
  
  def render_404 
    render(:file  => "#{::Rails.root.to_s}/public/404.html",   
    :status   => "404 Not Found") and return false
  end
  
  
  
  
  # ******************************************************************************************************** 
  if RAILS_ENV == 'production'
    include ExceptionHandler,ExceptionLoggable 
    rescue_from Exception do |exception|
      log_exception(exception)
      common_error
    end
    rescue_from ActiveRecord::RecordNotFound,:with => :record_not_found 
    rescue_from ActionController::UnknownAction,:with => :action_not_found
    rescue_from ActionController::RoutingError,:with => :action_not_found 
  end
  # *******************************************************************************************************
  
  
  def help
    Helper.instance
  end
  
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::SanitizeHelper
    include ApplicationHelper
  end
  
  def truncate(text, *args)
         options = args.extract_options!
         unless args.empty?
           ActiveSupport::Deprecation.warn('truncate takes an option hash instead of separate ' +
             'length and omission arguments', caller)
 
           options[:length] = args[0] || 30
           options[:omission] = args[1] || "..."
         end
         options.reverse_merge!(:length => 30, :omission => "...")
 
         if text
           l = options[:length] - options[:omission].mb_chars.length
           chars = text.mb_chars
           (chars.length > options[:length] ? chars[0...l] + options[:omission] : text).to_s
         end
  end
  
  def web_data(url)
    file_name = "tmp/#{Time.new.to_i}#{rand(100000)}"
    p "wget -T 10 -q -T40 -O #{file_name} '#{url}'"
    `wget -T 10 -q -T40 -O #{file_name} '#{url}'`
    #`curl -s -o #{file_name} '#{url}'`
    file = File.new(file_name, 'r')
    txt = file.read()
    file.close
    #`rm -f #{file_name}`
    return txt
  end
  
  def web_file(url)
    file_name = "tmp/#{Time.new.to_i}#{rand(100000)}"
    `wget -T 10 -q -T40 -O #{file_name} '#{url}'`
    #`curl -s -o #{file_name} '#{url}'`
    file_name
  end
  
  ##add by lmx,自从换了61.158.163.224服务器，Time.to_s方法变得很诡异，导致出bug，故新写此方法
  def time_str(time)
    weekday = %w(Sun Mon Tue Wed Thu Fri Sat)
    mon = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    
    "#{weekday[time.wday]} #{mon[time.month-1]} #{time.day} #{time.hour}:#{time.min}:#{time.sec} +0800 #{time.year}"
  end  
end
