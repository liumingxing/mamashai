require 'weibo'
require 'uri'
class AccountController < ApplicationController 
  before_filter :need_login_user,:only=>[:wizard_info, :wizard_info_action, :wizard_org_info,:wizard_follow,:wizard_follow_action,
                                         :wizard_org_info_action,:wizard_logo,:wizard_logo_upload,:wizard_logo_cropper,:wizard_logo_cropper_update,:resend_signup_email, :t2, :more_info_action]
  #before_filter :check_test_domain,:only=>[:login,:login_action,:index,:signup]
  
  layout "main"
  
  def blank
     render :text=>"<h1>登录成功</h1>"
  end
  
  def index 
    @title = '登录'
    @user = User.find_by_id(session[:uid]) if session[:uid]
    if @user
      redirect_to :controller=>'home',:action=>'index' 
    else
      render :action=>'login', :layout=>"main" and return false
    end
  end
  
  #################### login #########################
  
  def login
    @title = '登录'
    unless params[:id].blank?
      @user = User.find(params[:id]) 
      @user.password = nil
    end
    session[:origin_url] = params[:origin_url] if params[:origin_url].to_s.size > 0
  end
  
  def login_action 
    @title = '登录'
    @user,login_user = User.check_login_user(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip)
    unless @user.errors.empty?
      errors = []
      @user.errors.each do |attribute, errors_array|
        errors << errors_array
      end
      @errors  = errors.join(',')
      @user = nil
      render :action=>'login' and return false
    end
    
    session[:uid] = login_user.id.to_s 
    unless params[:is_save].blank?  
      enable_cookies(login_user)
    end
    
    if session[:origin_url]
      redirect_to session[:origin_url] 
      session[:origin_url] = nil
      return false
    end
    redirect_to :controller=>'index'
  end
  
  def m_login_action 
    @title = '登录'
    @user,login_user = User.check_login_user(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip)
    if @user.errors.empty?
      if params[:name]
        render :text=>login_user.id.to_s + ",#{@user.name}"
      elsif params[:id]
        render :text=>login_user.id.to_s
      else
        #render :text=>login_user.id.to_s
        render :text=>'0'
      end
    else
      render :text=>"error"
    end
  
  end
  
  def signup
    redirect_to :action=>"login" and return;

    
    render :text=>"对不起，本页已停用" and return;

    @title = '注册'
    session[:origin_url] = params[:origin_url] if params[:origin_url]
    session[:logo_require] = params[:logo_require] if params[:logo_require]
    @user_signup = User.new
    @user_signup.email = params[:email] if params[:email]
    @user_signup.user_kids_count = 1
    params[:signup_code] = params[:code] if params[:code]
    @invite_user = User.find(params[:id]) unless  params[:id].blank?

    @no_advertisement = true
    
    session[:origin_url] = params[:origin_url] if params[:origin_url].to_s.size > 0

  end
  
  def signup_action
    render :text=>"对不起，本页已停用" and return;
    
    @title = '注册'
    session[:origin_url] = params[:origin_url] if params[:origin_url]
    session[:logo_require] = params[:logo_require] if params[:logo_require]
    return render_404 if !params[:user_signup]
    unless params[:is_agree]
      flash[:flash_note] = 'error_signup_is_agree'
      redirect_to :action=>'signup',:id=>params[:user_signup][:invite_user_id] and return false
    end
    @user_signup = User.create_user_signup(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip) 
    unless @user_signup.errors.empty?
      @invite_user = User.find(params[:user_signup][:invite_user_id]) unless  params[:user_signup][:invite_user_id].blank?
      render :action=>'signup' and return false
    end
    session[:uid] = @user_signup.id.to_s 
    enable_cookies(@user_signup) 
    if session[:origin_url] and session[:logo_require].blank?
      origin_url = session[:origin_url]
      session[:origin_url] = nil
      redirect_to origin_url and return 
    end
    redirect_to :controller=>'account',:action=>'wizard_info'
  end
  
  def signup_success
    @title = '注册成功'
    @user_signup = User.find(params[:id])
  end
  
  def signup_email
    @title = '注册'
    return render_404 if params[:email].blank? or params[:event].blank?
    email = params[:email].strip.downcase
    @user_email = User.find_by_email(email)
    if @user_email.present?
      session[:uid] = @user_email.id.to_s 
      enable_cookies(@user_email)
      redirect_to :controller=>'event',:action=>params[:event] and return false
    end
    password = MamashaiTools::TextUtil.rand_8_num_str
    name = email.split('@')[0]
    while User.find_by_name(name).present? do
      name = name + MamashaiTools::TextUtil.rand_4_num_str 
    end
    params[:user_signup] = {:email=>email,:name=>name,:password=>password,:password_confirmation=>password,:user_kids_count=>0}
    @user_signup = User.create_user_signup(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip) 
    
    count_ad_keywords
    session[:uid] = @user_signup.id.to_s 
    enable_cookies(@user_signup)
    
    redirect_to :controller=>'account',:action=>'signup_email_success',:id=>@user_signup.id,:event=>params[:event],:p=>password
  end
  
  def signup_email_success
    @title = '注册成功'
    @user_signup = User.find(params[:id])
  end
  
  ############## org_signup #####################
  
  def org_signup
    @title = '机构注册'
    @user_signup = UserSignup.new
    @user_signup.email = params[:email] if params[:email]
    params[:signup_code] = params[:code] if params[:code]
    @invite_user = User.find(params[:id]) unless  params[:id].blank?
  end
  
  def org_signup_action
    @title = '注册成功'
    return render_404 if !params[:user_signup]
    age_ids = params[:age_ids].collect{|m| m[0] if m[1]=='1'}.compact
    org_tps = params[:org_tps].collect{|m| m[0] if m[1]=='1'}.compact
    params[:user_signup][:age_ids] = age_ids.join(',')
    params[:user_signup][:org_tps] = org_tps.join('|')
    
    unless params[:is_agree]
      flash[:flash_note] = 'error_signup_is_agree'
      redirect_to :action=>'org_signup' and return false
    end
    @user_signup = UserSignup.create_user_signup(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip) 
    unless @user_signup.errors.empty?
      render :action=>'org_signup' and return false
    end
    disable_cookies_and_session
    Mailer.deliver_email(Mailer.send_signup(@user_signup))
    
    session[:uid] = @user_signup.id.to_s
    enable_cookies(@user_signup)
    redirect_to :controller=>'account',:action=>'wizard_info'
  end
  
  def logout
    @title = '退出'
    disable_cookies_and_session
    redirect_to :controller=>'index', :action=>"index"
  end
  
  ####################### verify ###########################
  
  def resend_signup_email
    Mailer.deliver_email(Mailer.send_signup(@user))
    redirect_to :controller=>'account',:action=>'signup_email_success',:id=>@user.id
  end
  
  def verify
    @title = '邮件验证'
    @user = User.find_by_uuid(params[:id])
    if @user
      @user.update_attribute("is_verify",true)
      invite_user = @user.invite_user unless @user.invite_user_id.blank?
      invite_user = @user.invite_tuan_user unless @user.invite_tuan_user_id.blank?
      redirect_to :controller=>'account',:action=>'login',:id=>@user.id,:verify=>true and return false
    else
      redirect_to :controller=>'account',:action=>'user_verify_fail'
    end
  end
  
  def system_verify
    @user = User.find_by_uuid(params[:id])
    if @user
      @user.update_attribute("is_verify",true)
      flash[:notice]=email+"验证成功"
    else
      flash[:notice]=email+"验证失败"
    end
    redirect_to :controller=>'admin',:action=>'list_user_signups'
  end
  
  def verify_fail
  end
  
  def find_password
    @title = '找回密码'
    @user = User.new
  end
  
  def find_password_action
    @title = '找回密码'
    redirect_to :action => 'find_password' and return if params[:user].blank?
    @user = User.reset_password(params)
    
    unless @user.errors.empty?
      render :action=>'find_password' and return false
    end
    Mailer.deliver_email(Mailer.find_password(@user))
    redirect_to :action=>"find_password_success",:id=>@user.id
  end
  
  def find_password_success
    @title = '成功找回密码'
    @user1 = User.find(params[:id])
  end
  
  def resend_reset_password
    @user = User.find(params[:id])
    Mailer.deliver_email(Mailer.find_password(@user))
    redirect_to :action=>"find_password_success",:id=>@user.id
  end
  
  def confirm_reset_password
    @title = '确认密码'
    @user = User.confirm_reset_password_by_uuid(params[:id])
    redirect_to :controller=>'account',:action=>'reset_password_success',:id=>@user.id and return if @user
    redirect_to :controller=>'account',:action=>'reset_password_fail'
  end
  
  ################## wizard ########################
  
  def wizard_info
    @title = '完成注册资料'
    @user_kid1 = UserKid.new
    @user_kid1 = @user.user_kids[0] if @user.user_kids.size > 0
    @user_kid2 = @user.user_kids[1] if @user.user_kids.size > 1
    @user_kid3 = @user.user_kids[2] if @user.user_kids.size > 2
  end
  
  def wizard_info_action
    @user.update_attributes(params[:user])
    UserKid.delete_all("user_id = #{@user.id}")
    
    @user_kid1 = UserKid.new(params[:user_kid1])
    @user_kid2 = UserKid.new(params[:user_kid2]) if params[:user_kid2]
    @user_kid3 = UserKid.new(params[:user_kid3]) if params[:user_kid3]
    
    @user_kid1.user_id = @user.id
    @user_kid2.user_id = @user.id if params[:user_kid2]
    @user_kid3.user_id = @user.id if params[:user_kid3]
    
    @user_kid1.save if params[:user_kid1]
    @user_kid2.save if params[:user_kid2]
    @user_kid3.save if params[:user_kid3]
    
    if params[:user][:name] != @user.name       #修改了昵称，判断是否重复
      if User.find_by_name(params[:user][:name].strip)
        @user.errors.add(:name, '昵称已被占用') 
        @user.name = params[:user][:name].strip
        render :action => "wizard_info" and return
      end
    end
    
    @user.errors.add(:name,'请填写昵称') if @user.name.blank?
    @user.errors.add(:name,'您的输入超过了20个字符') if @user.name.length > 20
    @user.errors.add(:province_id,'请填写居住地') if @user.province_id.blank?
    @user_kid1.errors.add(:name, '请输入孩子昵称') if params[:user_kid1] && params[:user_kid1][:name].to_s.size == 0
    @user_kid2.errors.add(:name, '请输入孩子昵称') if params[:user_kid2] && params[:user_kid2][:name].to_s.size == 0
    @user_kid3.errors.add(:name, '请输入孩子昵称') if params[:user_kid3] && params[:user_kid3][:name].to_s.size == 0
    
    @user_kid1.errors.add(:gender1, '请输入孩子性别') if params[:user_kid1] && !params[:user_kid1][:gender]
    @user_kid2.errors.add(:gender1, '请输入孩子性别') if params[:user_kid2] && !params[:user_kid2][:gender]
    @user_kid3.errors.add(:gender1, '请输入孩子性别') if params[:user_kid3] && !params[:user_kid3][:gender]
    
    @user_kid1.errors.add(:birthday, '请输入孩子生日') if params[:user_kid1] && params[:user_kid1]["birthday(1i)"].to_i == 0
    @user_kid2.errors.add(:birthday, '请输入孩子生日') if params[:user_kid2] && params[:user_kid2]["birthday(1i)"].to_i == 0
    @user_kid3.errors.add(:birthday, '请输入孩子生日') if params[:user_kid3] && params[:user_kid3]["birthday(1i)"].to_i == 0
    
    if @user.errors.size > 0 || @user_kid1 && @user_kid1.errors.size > 0 || @user_kid2 && @user_kid2.errors.size > 0 || @user_kid3 && @user_kid3.errors.size > 0
      render :action=>"wizard_info"
    else
      redirect_to :action=>"wizard_logo"
    end
  end
  
  def wizard_follow
    @title = '寻找关注的人'
    @no_advertisement = true
  end
  
  def wizard_follow_action
    @title = '寻找关注的人'
    unless params[:follows].blank?
      ActiveRecord::Base.transaction do
        for user_id in params[:follows].collect{|m| m[0] if m[1]=='1'}.compact
          FollowUser.create_follow_user(User.find(user_id),@user)
        end
      end
    end
    
    if session[:origin_url]
      origin_url = session[:origin_url]
      session[:origin_url] = nil
      redirect_to origin_url and return 
    end
    redirect_to :controller=>"index" 
  end
  
  def wizard_gz
    @title = '完成注册'
    render :layout=>false
  end
  
  def wizard_logo
     @title = '上传头像'
  end
  
  def wizard_logo_upload
    @title = '上传头像'
    if (params[:user].blank? or params[:user][:logo].blank?) and params[:touxiang].blank?
      flash[:error] = '请上传或选择一张头像'
      redirect_to :action=>'wizard_logo' and return false
    end
    if params[:user][:logo]
      @user.update_attributes(params[:user])
    else
      file = File.open("public/images/login/logo/#{params[:touxiang]}.jpg", 'r')
      @user.logo = file
      @user.save
      file.close
      redirect_to :action=>"wizard_follow" and return
    end
    unless @user.errors.empty?
      redirect_to :action=>'wizard_logo' and return false
    end
    redirect_to :action=>'wizard_logo_cropper'
  end
  
  def wizard_logo_cropper
    @title = '上传头像'
  end
  
  def wizard_logo_cropper_update
    @title = '上传头像'
    MamashaiTools::ImageUtil.update_logos(@user,params[:logo_left],params[:logo_top],params[:logo_size],[140,48,30])
    User.update_invite_user_score(@user) 
    redirect_to :action=>"wizard_follow"
  end
  
  def login_from_qq
    session[:user_id] = params[:id] if params[:id]
    session[:token_from] = params[:from]
    session[:origin_url] = params[:origin_url]
    token = Weibotoken.get('qq', session[:token_from])  
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/account/login_from_qq_action")
    redirect_to "https://open.t.qq.com/cgi-bin/oauth2/authorize?response_type=code&client_id=#{token.token}&redirect_uri=#{oauth_callback}"
  end
  
  def login_from_qq_action
    session[:token_from] = session[:token_from]
    token = Weibotoken.get('qq', session[:token_from])
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/account/login_from_qq_action")
    text = `curl -F 'a=b' 'https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=#{token.token}&client_secret=#{token.secret}&grant_type=authorization_code&redirect_uri=#{oauth_callback}&code=#{params[:code]}'`

    res_hash = {}
    text.split("&").each{|pa|res_hash[pa.split('=')[0]] = pa.split('=')[1]}
    p res_hash

    text = `curl 'https://open.t.qq.com/api/user/info?format=json&oauth_consumer_key=#{token.token}&access_token=#{res_hash['access_token']}&openid=#{res_hash['openid']}&oauth_version=2.a&scope=all'`
    tencent_user = ActiveSupport::JSON.decode(text)
    p tencent_user
    user_qq = UserQq.find(:first, :conditions=>"(openid='#{res_hash['openid']}' or openid = '#{tencent_user['data']['name']}') and tp = 2")
    if !user_qq   #未绑定过
      user_qq         = UserQq.find_by_openid(tencent_user["data"]["name"])
      if user_qq     #绑定了其他key
        session[:uid] = user_qq.user.id
      elsif session[:uid].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:uid])
        if !user
          render :text=>"error" and return
        end
      else
        user = User.find_by_name(tencent_user["data"]["nick"])
        if !user
          user        = User.new
          user.email  = tencent_user['data']['name'] + "_tencent"
          user.password = "mamashai_qq"
          user.is_verify = true
          user.name   = tencent_user['data']['nick'] + "_tencent"
          user.gender = tencent_user['data']['sex'].to_s == "1" ? 'm' : 'w'
          user.from   = "腾讯微博绑定"
          file = open(tencent_user['data']["head"])
          user.logo = file
          user.save(:validate=>false)
          file.close if file
          File.delete(file.path) if file
          
          UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
          
          session[:uid] = user.id.to_s
          redirect_to '/account/more_info_from_weibo?tp=qq' and return
        else        #已经存在此昵称的账号
          flash[:notice] = "对不起，用户在妈妈晒的昵称是唯一的，当前已经存在昵称为#{user.name}的账号了。请先<a href='/account/signup'>注册</a>妈妈晒独有账号，然后在设置页绑定您的QQ账号，以后便可用QQ账号登陆。"
          redirect_to URI.escape("/account/more_info_from_weibo/#{user.id}?tp=qq&flash=#{flash[:notice]}")
          return
        end     
      end
    else          #绑定过
      if session[:uid]                            #已登陆
      else  
        session[:uid] = user_qq.user_id.to_s      #未登录  
      end
      user = User.find_by_id(session[:uid])
    end

    UserQq.delete_all("user_id = '#{user_qq.user_id}' and tp=2")
    UserQq.create(:user_id => user_qq.user_id, :openid=>res_hash['openid'], :name=>tencent_user['data']['name'], :tp=>2, :access_token=>res_hash['access_token'], :expire_at=>res_hash["expires_in"].to_i.seconds.from_now)
    
    if session[:origin_url]
        origin_url = session[:origin_url]
        session[:origin_url] = nil
        redirect_to origin_url and return 
    else
        redirect_to '/home'
    end
    session[:qqtoken] = session[:qqsecret] = nil
  end
  
  def login_from_tencent
    session[:user_id] = params[:id] if params[:id]
    session[:token_from] = params[:from]
    session[:origin_url] = params[:origin_url]
    token = Weibotoken.get('qq', session[:token_from])  
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/account/login_from_tencent_action")
    
    redirect_to "https://open.t.qq.com/cgi-bin/oauth2/authorize?client_id=#{token.token}&response_type=code&redirect_uri=#{oauth_callback}"
  end
  
  def login_from_tencent_action
    session[:token_from] = session[:token_from]
    token = Weibotoken.get('qq', session[:token_from])
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/account/login_from_tencent_action")
    text = `curl 'https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=#{oauth_callback}&grant_type=authorization_code&code=#{params[:code]}'`
    vars = text.split('&')
    logger.info text
    json_params = {}
    for v in vars
      json_params[v.split('=')[0]] = v.split('=')[1]
    end
    
    if !json_params['access_token']     #出错
      render :text=>"对不起，授权出错" and return;
    end
    
    access_token = json_params['access_token']
    expire_at = json_params['expires_in'].to_i.seconds.from_now
    
    text = `curl 'https://open.t.qq.com/api/user/info?oauth_consumer_key=#{token.token}&access_token=#{access_token}&openid=#{params[:openid]}&oauth_version=2.a&scope=all'`
    json = ActiveSupport::JSON.decode(text)['data']
    uid = json['openid']
    
    user_tencent = UserQq.find(:first, :conditions=>"openid = '#{uid}'")
    if user_tencent && user_tencent.user  #绑定过
      if !session[:uid]                                     #有登录信息
         user = user_tencent.user
      else
         user= User.find_by_id(session[:uid])
      end
    else            #没绑定过
      if session[:uid].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:uid])
        if !user
          render :text=>"error" and return
        end
      else                              #没传入用户，注册
        user_tencent = UserQq.find(:first, :conditions=>"openid = '#{uid}'")
        if user_tencent  #是妈妈晒用户，但绑定的是其他key
          user = user_tencent.user
        else
          user        = User.find_by_email(json["nick"]+ "_tencent")
          if !user                        #有重名
            user        = User.new
            user.gender = json["sex"]=='2' ? 'm' : 'w'
            user.province_id, user.city_id = trans_city_by_name(json["location"])
            user.email  = json["name"] + "tencent"
            user.password = "mamashai"
            user.is_verify = true
            user.name   = User.find_by_name(json["nick"]) ? json["nick"] + "_tencent" : json["nick"] 
            user.logo   = open(json["head"]) if json["head"].to_s.size > 0 
            user.from   = '腾讯微博绑定'
            user.save(:validate=>false)
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserQq.delete_all("openid = '#{uid}' and tp = #{token.tp}") 
            UserQq.create(:user_id=>user.id, :tp=>token.tp, :openid=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
            
            session[:uid] = user.id.to_s    
            redirect_to :action=>"wizard_info" and return
          end
        end        
      end
    end
    
    UserQq.delete_all("user_id = '#{user.id}' and tp = #{token.tp}") 
    UserQq.delete_all("openid = '#{uid}' and tp = #{token.tp}") 
    UserQq.create(:user_id=>user.id, :tp=>token.tp, :openid=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
    
    session[:uid] = user.id.to_s         
    
    if session[:origin_url]
        origin_url = session[:origin_url]
        session[:origin_url] = nil
        redirect_to origin_url and return 
    end
    
    redirect_to :controller=>"index"   
  end
  
  def login_from_weibo
    session[:user_id] = params[:id] if params[:id]
    session[:token_from] = params[:from]
    session[:origin_url] = params[:origin_url]
    token = Weibotoken.get('sina', session[:token_from])  
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/account/login_from_weibo_action")
    redirect_to "https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&client_id=#{token.token}&redirect_uri=#{oauth_callback}"
  end
  
  def login_from_weibo_action
    session[:token_from] = session[:token_from]
    token = Weibotoken.get('sina', session[:token_from])
    text = `curl -F 'a=b' 'https://api.weibo.com/oauth2/access_token?client_id=#{token.token}&client_secret=#{token.secret}&grant_type=authorization_code&redirect_uri=http%3A%2F%2Fwww.mamashai.com%2Fapi%2Faccount%2Fbaby_calendar_mobile_callback&code=#{params[:code]}'`
    json = ActiveSupport::JSON.decode(text)
    if json['error_code']     #出错
      render :text=>"对不起，授权出错" and return;
    end

    uid = json['uid']
    access_token = json['access_token']
    expire_at = json['expires_in'].to_i.seconds.from_now
   
    token = Weibotoken.get('sina', session[:token_from])
    text = `curl 'https://api.weibo.com/2/account/get_uid.json?source=#{token.token}&access_token=#{access_token}'`
    logger.info text
    logger.info "curl 'https://api.weibo.com/2/users/show.json?uid=#{uid}source=#{token.token}&access_token=#{access_token}'"
    text = `curl 'https://api.weibo.com/2/users/show.json?uid=#{uid}&source=#{token.token}&access_token=#{access_token}'`
    sina_user = ActiveSupport::JSON.decode(text)
    
    user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{sina_user['id']}'")
    if user_weibo && user_weibo.user  #绑定过
      if !session[:uid]                                     #有登录信息
         user = user_weibo.user
      else
         user= User.find_by_id(session[:uid])
      end
    else            #没绑定过
      if session[:uid].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:uid])
        if !user
          render :text=>"error" and return
        end
      else                              #没传入用户，注册
        user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{uid}'")
        if user_weibo  #是妈妈晒用户，但绑定的是其他key
          UserWeibo.create(:user_id=>user_weibo.user_id, :tp=>token.tp, :access_id=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
          user = user_weibo.user
        else
          user        = User.find_by_email(sina_user["name"])
          if !user                        #有重名
            user        = User.new
            user.gender = sina_user["gender"]=='m' ? 'm' : 'w'
            user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
            user.email  = sina_user["name"] + "_sina"
            user.password = "mamashai"
            user.is_verify = true
            user.name   = User.find_by_name(sina_user["name"]) ? sina_user["name"] + "_weibo" : sina_user["name"] 
            user.logo   = open(sina_user["profile_image_url"]) if sina_user["profile_image_url"].to_s.size > 0 
            user.from   = '新浪微博绑定'
            user.save(:validate=>false)
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserWeibo.delete_all("access_id = #{uid} and tp = #{token.tp}") 
            UserWeibo.create(:user_id=>user.id, :tp=>token.tp, :access_id=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
    
            session[:uid] = user.id.to_s    
            redirect_to :action=>"wizard_info" and return
          end
        end        
      end
    end
    
    UserWeibo.delete_all("access_id = #{uid} and tp = #{token.tp}") 
    UserWeibo.create(:user_id=>user.id, :tp=>token.tp, :access_id=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
    
    session[:uid] = user.id.to_s         
    
    if session[:origin_url]
        origin_url = session[:origin_url]
        session[:origin_url] = nil
        redirect_to origin_url and return 
    end
    
    redirect_to :controller=>"index"   
  end
  
  def login_from_taobao
    session[:token_from] = params[:from] || 'baby_calendar'
    token = Weibotoken.get('taobao', session[:token_from])  
    session[:origin_url] = params[:origin_url]
    #redirect_to "https://oauth.taobao.com/authorize?client_id=#{token.token}&redirect_uri=http%3A%2F%2Fwww.mamashai.com%2Faccount%2Flogin_from_taobao_callback&response_type=code&scope=item%2Cpromotion%2Citem%2Cusergrade&state=7d0fb3f3ed08d20b13f41bcc442fa4ea"
    redirect_to "https://oauth.taobao.com/authorize?response_type=code&state=#{[session[:token_from], params[:id]].join(',')}&client_id=#{token.token}&redirect_uri=http://www.mamashai.com/account/login_from_taobao_callback"
  end
  
  def login_from_taobao_callback
    session[:token_from] ||= 'baby_calendar'
    if params[:state]
      arr = params[:state].split(',')
    end
    token = Weibotoken.get('taobao', session[:token_from])
    http = Net::HTTP.new("oauth.taobao.com", 443)
    http.use_ssl = true
    logger.info 'https://oauth.taobao.com/token' + "code=#{params[:code]}&grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=http://www.mamashai.com/account/login_from_taobao_callback"
    #resp, data = http.post('https://oauth.taobao.com/token', "code=#{params[:code]}&grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=http://www.mamashai.com:3000/account/login_from_taobao_callback")
    data = `curl -d "1=1" "https://oauth.taobao.com/token?code=#{params[:code]}&grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=http://www.mamashai.com/account/login_from_taobao_callback"`
    logger.info data
    json = ActiveSupport::JSON.decode(data)
    uid = json['taobao_user_id']
    nick = URI.decode(json['taobao_user_nick'])
    
   user_taobao = UserTaobao.find(:first, :conditions=>"taobao_id = '#{uid}' and tp = #{token.tp}")
   if user_taobao && user_taobao.user           #绑定过
      if !session[:uid]                                     #有登录信息
         user = user_taobao.user
      else
         user= User.find_by_id(session[:uid])
      end
   else                                         #没绑定过
      if arr && arr.size == 0 && arr[1].length > 0     #传入了用户，绑定
        user = User.find_by_id(arr[1])
        if !user
          render :text=>"对不起，发生错误" and return
        end
      elsif session[:uid]
        user = User.find_by_id(session[:uid])
      else                                      #没传入用户，注册
        user_taobao = UserTaobao.find(:first, :conditions=>"taobao_id = '#{uid}'")
        if user_taobao                          #是妈妈晒用户，但绑定的是其他key
          user = user_taobao.user
        else
          user        = User.find_by_email(json["taobao_user_nick"])
          if !user                        #有重名
            user        = User.new
            user.email  = URI.decode(json["taobao_user_nick"] + "_taobao")
            user.password = "mamashai"
            user.is_verify = true
            user.name   = URI.decode(User.find_by_name(json["taobao_user_nick"]) ? json["taobao_user_nick"] + "_taobao" : json["taobao_user_nick"]) 
            user.from   = '淘宝授权'
            user.save(:validate=>false)
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserTaobao.delete_all("taobao_id = '#{uid}' and tp = #{token.tp}") 
            UserTaobao.create(:user_id=>user.id, :tp=>token.tp, :taobao_id=>uid, :taobao_nick=>json['taobao_user_nick'], :access_token=>json['access_token'], :expire_at=>Time.now.to_i + json['expires_in'].to_i, :refresh_token=>json['refresh_token'], :re_expire_at=>Time.new.to_i + json['re_expires_in'].to_i)
            
            session[:uid] = user.id.to_s
            redirect_to :action=>"wizard_info" and return
          end
        end        
      end
    end
    
    UserTaobao.delete_all("taobao_id = '#{uid}' and tp = #{token.tp}") 
    UserTaobao.create(:user_id=>user.id, :tp=>token.tp, :taobao_id=>uid, :taobao_nick=>json['taobao_user_nick'], :access_token=>json['access_token'], :expire_at=>Time.now.to_i + json['expires_in'].to_i, :refresh_token=>json['refresh_token'], :re_expire_at=>Time.new.to_i + json['re_expires_in'].to_i)
    
    
    session[:uid] = user.id.to_s         
    
    if session[:origin_url]
        origin_url = session[:origin_url]
        session[:origin_url] = nil
        redirect_to origin_url and return 
    end
    
    redirect_to :controller=>"index"   
  end
  
  def more_info_from_weibo
    @user = User.find(session[:uid]) if session[:uid]
    @no_advertisement = true
    @user_signup = User.new(:user_kids_count=>1)
    flash[:notice] = params[:flash] if params[:flash]
    @user = User.find(params[:id]) if params[:id]
  end
  
  def login_from_baidu
    session[:uid] = params[:id] if params[:id]
    token = Weibotoken.get('baidu', params[:from])
    oauth_callback = CGI::escape("http://www.mamashai.com/account/login_from_baidu_action?from=#{params[:from]}")
    redirect_to "https://openapi.baidu.com/oauth/2.0/authorize?response_type=code&display=mobile&client_id=#{token.token}&redirect_uri=#{oauth_callback}"
    session[:origin_url] = params[:origin_url]
  end
  
  def login_from_baidu_action
    token = Weibotoken.get('baidu', params[:from])
    oauth_callback = CGI::escape("http://www.mamashai.com/account/login_from_baidu_action?from=#{params[:from]}")
    text = `curl 'https://openapi.baidu.com/oauth/2.0/token?grant_type=authorization_code&code=#{params[:code]}&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=#{oauth_callback}'`
    json = ActiveSupport::JSON::decode(text)
    
    text = `curl 'https://openapi.baidu.com/rest/2.0/passport/users/getLoggedInUser?access_token=#{json['access_token']}'`
    user_info = ActiveSupport::JSON::decode(text)   
    
    user_baidu = UserBaidu.find(:first, :conditions=>"baidu_id = #{user_info['uid']}")
    if !user_baidu || !user_baidu.user     #从未绑定过
      if !session[:uid] #不是妈妈晒用户过来的
        user        = User.find_by_name(user_info["uname"] + "_baidu")
        if !user        #主表没有这个用户账号
          user        = User.new
          user.gender = 'w'      #默认是妈妈
          #user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
          user.email  = user_info["uname"] + "_baidu"
          user.password = "mamashai"
          user.is_verify = true
          user.name   = User.find_by_name(user_info["uname"]) ? user_info["uname"] + "_baidu" : user_info["uname"]
          user.from = token.desc
          
          file, path = open_url_file("http://himg.bdimg.com/sys/portraitn/item/#{user_info['portrait']}.jpg")
          user.logo = file
          
          user.save(:validate=>false)
          file.close
          File.delete(path)
          
          UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
        else        #主表有这个账号
          baidu = UserBaidu.find(:first, :conditions=>"baidu_id=#{user_info["uid"]}")
          if baidu      #且绑定了新浪微博
            @user = baidu.user
          else
            @user = user
            params[:flash] = "对不起，用户在妈妈晒的昵称是唯一的，系统当前已经存在昵称为 <b>#{user.name}</b> 的账号了。请先<a href='/account/signup'>注册</a>妈妈晒独有账号，然后在设置页绑定您的百度账号，以后便可用微博账号登陆。"
            @no_advertisement = true
            @user_signup = User.new(:user_kids_count=>1)
            render :action=>"more_info_from_weibo", :layout=>"index"
            return
          end
        end
        UserBaidu.delete_all("baidu_id = #{user_info['uid']} and tp = #{token.tp}") 
        UserBaidu.create(:user_id=>user.id, :tp=>token.tp, :expire_at=> Time.new.since(json['expires_in']), :baidu_id=>user_info['uid'], :token=>json['access_token'], :refresh_token=>json['refresh_token'])
          
        session[:uid] = user.id.to_s 
      else              #是妈妈晒用户
        user = User.find(session[:uid])
        UserBaidu.delete_all("baidu_id = #{user_info['uid']} and tp = #{token.tp}") 
        UserBaidu.create(:user_id=>session[:uid], :tp=>token.tp, :expire_at=> Time.new.since(json['expires_in']), :baidu_id=>user_info['uid'], :token=>json['access_token'], :refresh_token=>json['refresh_token'])
      end
      
      session[:uid] = user.id.to_s
      if session[:origin_url]                   #有返回地址
          redirect_to session[:origin_url]
          session[:origin_url] = nil
      else                                      #无返回地址,返回给手机用的js  
          
      end
    else              #绑定过
      UserBaidu.delete_all("baidu_id = #{user_info['uid']} and tp = #{token.tp}")
      user_baidu = UserBaidu.create(:user_id=>user_baidu.user_id, :tp=>token.tp, :expire_at=> Time.new.since(json['expires_in']), :baidu_id=>user_info['uid'], :token=>json['access_token'], :refresh_token=>json['refresh_token'])
      user = user_baidu.user
      session[:uid] = user_baidu.user_id.to_s
      if session[:origin_url]                 #有返回地址
          origin_url = session[:origin_url]
          session[:origin_url] = nil
          redirect_to origin_url and return 
      else                                    #无返回地址
          
      end
    end
    
    @token = json["access_token"]
    @secret = ""
    @expire = Time.new.since(json['expires_in']).to_i
    @user = user
    if params[:from] == "lama"
      render :layout=>false
      #render :text => {"token"=>@token, "secret"=>@secret, "expire_at"=>@expire,"user"=>@user.to_json}.to_json
    else  
      render :layout=>false
    end
  end
  
  def more_info_already_user
    if session[:uid]
      if !Post.find(:first, :conditions=>"user_id = #{session[:uid]}")
        User.find(session[:uid]).destroy
      end
      
      disable_cookies_and_session
    end
    redirect_to :controller=>"settings", :action=>"weibo"
  end
  
  def more_info_action
    if params[:user_signup]
      @user.user_kids_count = params[:user_signup][:user_kids_count]
      @user.save(:validate=>false)
      
      if @user.user_kids_count > 0
        user_signup = User.new(params[:user_signup])
        @user.first_kid = UserKid.create(:user_id=>@user.id,:birthday=>user_signup.birthday, :gender=>user_signup.gender)
        @user.save(:validate=>false)
      end
    end
    
    if session[:origin_url]
      origin_url = session[:origin_url]
      session[:origin_url] = nil
      redirect_to origin_url 
    else
      redirect_to :controller=>"settings"
    end
  end
  
#  def login_as_weibo  
#    return_text = `curl -u "#{params[:user][:email]}:#{params[:user][:password]}" "http://api.t.sina.com.cn/account/verify_credentials.json?source=3095465835"`
#    return_hash = ActiveSupport::JSON.decode(return_text)
#    if return_hash[:error]
#      render :text=>return_hash[:error] and return false
#    else
#      params[:user][:name] = fetch_unique_name(return_hash["name"])
#      params[:user][:password_confirmation] = params[:user][:password]
#      params[:user][:user_kids_count] = 0
#      params[:user][:gender] = return_hash["gender"]
#      params[:user][:logo] = open(return_hash["profile_image_url"]) if return_hash["profile_image_url"].to_s.size > 0 
#      params[:user][:province_id], params[:user][:city_id] = trans_city(return_hash["province"], return_hash["city"])
#      @user_signup = User.create_user_signup(params,request.remote_ip) 
#      unless @user_signup.errors.empty?
#        @invite_user = User.find(params[:user_signup][:invite_user_id]) unless  params[:user][:invite_user_id].blank?
#        errors = []
#        @user_signup.errors.each do |attribute, errors_array|
#          errors << errors_array
#        end
#        render :text=>errors.join(";")
#      end
#      UserWeibo.create(:user_id => @user_signup.id, :password=>params[:user][:password], :tp=>1)
#      count_ad_keywords
#      session[:uid] = @user_signup.id.to_s 
#      enable_cookies(@user_signup) 
# 
#      if session[:origin_url] and session[:logo_require].blank?
#        origin_url = session[:origin_url]
#        session[:origin_url] = nil
#        redirect_to origin_url and return 
#      end
#      render :text=>"1"
#    end
#  end

  
  def t1
    @title = '注册'
    session[:origin_url] = params[:origin_url] if params[:origin_url]
    session[:logo_require] = params[:logo_require] if params[:logo_require]
    @user_signup = User.new
    @user_signup.email = params[:email] if params[:email]
    @user_signup.user_kids_count = 1
    params[:signup_code] = params[:code] if params[:code]
    @invite_user = User.find(params[:id]) unless  params[:id].blank?
    @no_advertisement = true
  end

  def t2
    @no_advertisement = true
  end
  
  def t3
    @no_advertisement = true
  end
  
  def t4
    @no_advertisement = true
  end
  
  def t5
    @no_advertisement = true
  end
  
  def t6
    @no_advertisement = true
  end
  
  def t7
    render :layout=>false
  end

  def login_from_qq2
    token = Weibotoken.get('qzone', 'baby_calendar')
    redirect_to "https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=#{token.token}&state=100&redirect_uri=http://www.mamashai.com/account/login_from_qq2_callback&display=mobile&scope=upload_pic,add_one_blog,get_info,add_t,add_pic_t,add_topic,add_share"
  end

  def login_from_qq2_callback
    token = Weibotoken.get('qzone', 'baby_calendar')
    text = `curl 'https://graph.qq.com/oauth2.0/token?grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&code=#{params[:code]}&state=#{params[:state]}&redirect_uri=http://www.mamashai.com/account/login_from_qq2_callback'`
    p text
    arr = text.split('&')
    tokens = {}
    for a in arr
      tokens[a.split('=')[0]] = a.split('=')[1]
    end
    p tokens

    text = `curl https://graph.qq.com/oauth2.0/me?access_token=#{tokens['access_token']}`
    logger.info text
    text = text.scan(/{[\W\w]+}/)[0]
    open_ids = ActiveSupport::JSON.decode(text)

    user_qzone = UserQzone.find(:first, :conditions=>"openid = '#{open_ids['openid']}'")
    if user_qzone && user_qzone.user  #绑定过
      if !session[:uid]                                     #有登录信息
         user = user_qzone.user
      else
         user= User.find_by_id(session[:uid])
      end
      user_qzone.access_token=tokens['access_token']
      user_qzone.expire_at=Time.new.to_i + tokens['expires_in'].to_i
      user_qzone.save

      UserQzone.delete_all("openid = '#{open_ids['openid']}' and tp = #{token.tp}") 
      UserQzone.create(:user_id=>user.id, :nick=>user.name, :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i) rescue nil
    
    else            #没绑定过
      if session[:uid].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:uid])
        if !user
          render :text=>"error" and return
        end
        UserQzone.create(:user_id=>user.id, :nick=>user.name, :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i) rescue nil
      else                              #没传入用户，注册
        user_qzone = User.find(:first, :conditions=>"email = '#{open_ids['openid']}'")
        if user_qzone  #是妈妈晒用户，但绑定的是其他key
          user = user_qzone
        else
          user        = User.find_by_email(open_ids['open_id'])
          if !user                        #有重名
            text = `curl 'https://graph.qq.com/user/get_simple_userinfo?access_token=#{tokens['access_token']}&oauth_consumer_key=#{token.token}&openid=#{open_ids['openid']}'`
            json = JSON.parse(text)
            p json

            user        = User.new
            user.gender = json["gender"]=='男' ? 'm' : 'w'
            #user.province_id, user.city_id = trans_city_by_name(json["location"])
            user.email  = open_ids['openid']
            user.password = "mamashai"
            user.is_verify = true
            1.upto(1000) do |i|
              name = json["nickname"] + (i == 1 ? "" : i.to_s)
              if !User.find(:first, :conditions=>"name = '#{name}'")
                user.name = name
                break
              end
            end
            user.logo   = open(json["figureurl_2"]) if json["figureurl_2"].to_s.size > 0 
            user.from   = 'qq绑定'
            user.save(validate=>false)
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserQzone.delete_all("openid = '#{open_ids['openid']}' and tp = #{token.tp}") 
            UserQzone.create(:user_id=>user.id, :nick=>json["nickname"], :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i)
            
            session[:uid] = user.id.to_s    
            redirect_to :action=>"wizard_info" and return
          end
        end        
      end
    end
    
    session[:uid] = user.id.to_s         
    
    if session[:origin_url]
        origin_url = session[:origin_url]
        session[:origin_url] = nil
        redirect_to origin_url and return 
    end
    
    redirect_to :controller=>"index"   

  end
  
private

 def fetch_unique_name(text)
    u = User.find_by_name(text)
    index = 1
    result = text
    while u
      result = text + index.to_s
      u = User.find_by_name(result)
      index += 1
    end
    return result  
 end
 
 def trans_city_by_name(location)
   locations = location.split(' ')
   m_province_id = m_city_id = nil
   if locations.size > 0
     province = Province.find_by_name(locations[0])
     m_province_id = province.id if province
     m_city_id     = City.find_by_province_id_and_name(m_province_id, locations[1]) if m_province_id  && locations.size > 1
   end
   return m_province_id, m_city_id
 end
 
 def trans_city(province_id, city_id)
    city_text = `curl http://api.t.sina.com.cn/provinces.json`
    city_hash = ActiveSupport::JSON.decode(city_text)
    province_name = city_name = nil
    for province in city_hash["provinces"]
      if province["id"].to_s == province_id.to_s
        province_name = province["name"]
        for city in province["citys"]
          if city["id"].to_s == city_id.to_s
            city_name = city["name"] 
            break
          end
        end
        break
      end
    end
    m_province_id = m_city_id = nil
    province = Province.find_by_name(province_name)
    m_province_id = province.id if province
    m_city_id     = City.find_by_province_id_and_name(m_province_id, city_name) if m_province_id && city_name
    return m_province_id, m_city_id
 end
 
 def open_url_file(url)
    name = url.split('/').last
    path = File.join(::Rails.root.to_s, 'tmp', "#{Time.new.to_i}#{name}")
    `wget -O #{path} #{url}`
    file = File.open(path)
    return file, path
  end
 
 def open(url)
    `rm -f /tmp/#{url.split('/').last}`
    `wget -T 10 -P /tmp #{url}`
    begin
      file = File.open("/tmp/" + url.split('/').last, 'rb')
    rescue => err
      p err
      return nil
    end
    return file
  end
  
  
      def build_oauth_token_key(name, oauth_token)
        [name, oauth_token].join("_")
      end
  
end
