class SettingsController < ApplicationController 
  before_filter :need_login_user
  layout 'main'
  
  def index
    if @user.org_profile_id
      redirect_to :action=>'org_profile'
    else
      redirect_to :action=>'profile'
    end
  end
  
  def test
    render :layout=>false
  end
  
  ############ password ###############
  
  def password
    @user.password = nil
  end 
  
  def update_password
    @user.update_password(params)
    unless @user.errors.empty?
      @user.password = nil
      render :action=>'password' and return false
    end
    redirect_to :action=>'password',:success=>true 
  end
  
  ############## domain #################
  
  def domain
    
  end
  
  def update_domain 
    @user.update_user_domain(params[:user][:domain]) if params[:user]
    unless @user.errors.empty?
      render :action=>'domain' and return false
    end 
    @user.domain
    redirect_to :action=>'domain',:success=>true,:score=>0
  end
  
  ############## profile ################
  
  def profile
    @user_profile = @user.user_profile
    @user_kid1 = UserKid.new
    @user_kid1 = @user.user_kids[0] if @user.user_kids.size > 0
    @user_kid2 = @user.user_kids[1] if @user.user_kids.size > 1
    @user_kid3 = @user.user_kids[2] if @user.user_kids.size > 2
  end
  
  def update_profile 
    if !params[:user]
      redirect_to :action=>'profile' and return
    end
    pass = @user.password
    #@user.password = "abc"
    @user,@user_profile = UserProfile.update_user_profile(params,@user) 
    @user.password = pass
    @user.save(:validate=>false)
    unless @user.errors.empty?
      @user_profile = @user.user_profile
      @user_kid1 = UserKid.new
      @user_kid1 = @user.user_kids[0] if @user.user_kids.size > 0
      @user_kid2 = @user.user_kids[1] if @user.user_kids.size > 1
      @user_kid3 = @user.user_kids[2] if @user.user_kids.size > 2
      render :action=>'profile' and return false
    end
    
    1.upto(3) do |i|
      if params["user_kid#{i}"]
        if params["user_kid#{i}"][:id].to_s.size > 0
          kid = UserKid.find(params["user_kid#{i}"][:id])
          kid.update_attributes(params["user_kid#{i}"])
        else
          kid = UserKid.new(params["user_kid#{i}"])
          kid.user_id = @user.id
          kid.save
        end
      end
    end
    
    redirect_to :action=>'profile',:success=>true
  end
  
  ############## tags ################
  
  def tags
    
  end
  
  def update_tags
    age_ids = params[:age_ids].collect{|m| m[0] if m[1]=='1'}.compact
    tag_ids = params[:tag_ids].collect{|m| m[0] if m[1]=='1'}.compact
    @user.update_attributes(:age_ids=>age_ids.sort.join(','),:tag_ids=>tag_ids.sort.join(','))
    @user.save(:validate=>false)
    redirect_to :action=>'tags',:success=>true 
  end
  
  ################ kids ###################
  
  def kids 
    @user_kids = @user.user_kids
    @user_kid1 = UserKid.new
    @user_kid1 = @user_kids[0] if @user_kids.length>=1
    @user_kid2 = @user_kids[1] if @user_kids.length>=2
    @user_kid3 = @user_kids[2] if @user_kids.length>=3
  end
  
  def update_kids  
    success,@user_kid1,@user_kid2,@user_kid3 = UserKid.update_user_kids(@user,params)
    @user_kids = @user.user_kids
    success = false unless @user_kid1.is_signuped
    if params[:user] 
      @user.attributes = params[:user]
      @user.save
    end
    
    if success
      redirect_to :action=>'kids',:success=>true
    else
      render :action=>'kids' and return false
    end
  end
  
  def add_user_kid
    @user_kid1 = UserKid.new if params[:user_kid] == "1"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid1,:user_kid_obj=>'user_kid1'} and return if @user_kid1
    @user_kid2 = UserKid.new if params[:user_kid] == "2"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid2,:user_kid_obj=>'user_kid2'} and return if @user_kid2
    @user_kid3 = UserKid.new if params[:user_kid] == "3"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid3,:user_kid_obj=>'user_kid3'} and return if @user_kid3
  end
  
  ################ blog ###################
  
  def blog
    @blog_hash = {}
    @user.user_blogs.each do |blog|
      @blog_hash.merge!({blog.blog_tp=>blog.blog_name})
    end
  end
  
  def update_qq
    if params[:tp] == "cancel"      #取消绑定无需输入帐号密码
      UserQq.delete_all("user_id = #{@user.id}")
      redirect_to :action=>"weibo", :success=>true and return
    end
    
    consumer = OAuth::Consumer.new(QQ_KEY, QQ_SECRET, CONSUMER_OPTIONS)
    request_token = consumer.get_request_token()
    session[:qqtoken] = request_token.token
    session[:qqsecret] = request_token.secret
    
    redirect_to request_token.authorize_url + "&oauth_consumer_key=205799&oauth_callback=http%3A%2F%2Fwww.mamashai.com%2Fsettings%2Fupdate_qq_action"
  end
  
  def update_qq_action
    consumer = OAuth::Consumer.new(QQ_KEY, QQ_SECRET, CONSUMER_OPTIONS)
    request_token = ::OAuth::RequestToken.new(consumer, session[:qqtoken], session[:qqsecret])
    access_token = request_token.get_access_token(:oauth_vericode => params[:oauth_vericode])
    
    UserQq.delete_all("user_id = #{@user.id}")
    UserQq.create(:user_id => @user.id, :tp=>1, :openid => params[:openid], :access_token=>access_token.token, :access_secret=>access_token.secret)
    
    session[:qqtoken] = session[:qqsecret] = nil
    redirect_to :controller=>"account", :action=>"opener_nav", :url=>'/settings/weibo?success=true', :layout=>false
  end
  
  def update_tencent_weibo
    if params[:tp] == "cancel"      #取消绑定无需输入帐号密码
      UserQq.delete_all("user_id = #{@user.id}")
      redirect_to :action=>"weibo", :success=>true and return
    end
    
    consumer = OAuth::Consumer.new(QQ_KEY, QQ_SECRET, CONSUMER_OPTIONS)
    request_token = consumer.get_request_token(:oauth_callback => "http://#{request.env["HTTP_HOST"]}/settings/update_tencent_weibo_action")
    
    session[:qqtoken] = request_token.token
    session[:qqsecret] = request_token.secret
    
    redirect_to request_token.authorize_url 
  end
  
  def update_tencent_weibo_action
    consumer = OAuth::Consumer.new(QQ_KEY, QQ_SECRET, CONSUMER_OPTIONS)
    request_token = ::OAuth::RequestToken.new(consumer, session[:qqtoken], session[:qqsecret])
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    
    tencent_user = ActiveSupport::JSON.decode(access_token.get("http://open.t.qq.com/api/user/info?format=json").body)
    
    UserQq.delete_all("openid = '#{tencent_user['data']['name']}' and tp = 2")
    UserQq.create(:user_id=>@user.id, :openid=>tencent_user['data']['name'], :access_token=>access_token.token, :access_secret=>access_token.secret, :tp=>2)
    
    session[:qqtoken] = session[:qqsecret] = nil
    
    redirect_to :action=>"weibo", :success=>true
  end

  def update_qzone
    if params[:tp] == "cancel"      #取消绑定无需输入帐号密码
      UserQzone.delete_all("user_id = #{@user.id} and tp = 1")
    end
    
    redirect_to :action=>"weibo", :success=>true and return
  end
  
  def update_taobao
    if params[:tp] == "cancel"      #取消绑定无需输入帐号密码
      UserTaobao.delete_all("user_id = #{@user.id} and tp = 1")
    end
    
    redirect_to :action=>"weibo", :success=>true and return
  end
  
  def update_weibo
    if params[:tp] == "cancel"      #取消绑定无需输入帐号密码
      UserWeibo.delete_all("user_id = #{@user.id} and tp = 1")
      redirect_to :action=>"weibo", :success=>true and return
    end
    
    begin
      oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
      request_token = oauth.consumer.get_request_token
    rescue
      sleep(2)
      oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
      request_token = oauth.consumer.get_request_token
    end

    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/settings/update_weibo_action")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    session[:weibo_tp] = params[:tp]
    redirect_to "#{request_token.authorize_url}&oauth_callback=#{oauth_callback}"
  end
  
  def update_weibo_action
    begin
      oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
      oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
    rescue
      begin
        sleep(2)
        oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
        oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
      rescue
        sleep(2)
        oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
        oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
      end
    end
    sina_user = Weibo::Base.new(oauth).verify_credentials
    
    UserWeibo.delete_all("access_id = '#{sina_user.id}'")
    UserWeibo.create(:user_id=>@user.id, :access_id=>sina_user.id, :access_token=>oauth.access_token.token, :access_secret=>oauth.access_token.secret, :tp=>1)
    
    session[:rtoken] = session[:rsecret] = session[:weibo_tp] = nil
    
    redirect_to :action=>"weibo", :success=>true
  end
  
  def update_weibo_to
    if params[:tp] == "sina"
      user_weibo = UserWeibo.find(params[:id])
      user_weibo.update_attributes(params[:user_weibo])
    end
    
    if params[:tp] == "qq"
      user_weibo = UserQq.find(params[:id])
      user_weibo.update_attributes(params[:user_qq])
    end
    
    redirect_to :action=>"weibo", :success=>true
  end
  
  def update_blog
    UserBlog.update_user_blogs(params,@user) 
    redirect_to :action=>'blog',:success=>true
  end
  
  def update_blog_content
    user_blog = UserBlog.find_by_blog_tp_and_user_id(params[:id],@user.id)
    UserBlog.update_user_blog_posts(user_blog,@user)
    redirect_to :action=>'blog',:success=>true 
  end
  
  ################ logo ###################
  
  def logo 
  end
  
  def update_logo
    if (params[:user].blank? or params[:user][:logo].blank?) and params[:touxiang].blank?
      redirect_to :action=>'logo' and return false
    end
    
    if params[:user][:logo]
      #@user.update_attributes(params[:user])
      @user.attributes = params[:user]
      @user.save(:validate=>false)
    else
      file = File.open("public/images/login/logo/#{params[:touxiang]}.jpg", 'rb')
      @user.logo = file
      @user.save(:validate=>false)
      @user.upload_to_aliyun
      file.close
    end
    unless @user.errors.empty?
      render :action=>'logo' and return false
    end
    
    if params[:user][:logo]
      redirect_to :action=>'logo',:cropper=>true
    else
      redirect_to :action=>"logo"
    end
  end
  
  def update_logo_cropper
    MamashaiTools::ImageUtil.update_logos(@user,params[:logo_left],params[:logo_top],params[:logo_size],[140,48,30])
    redirect_to :action=>'logo',:success=>true
  end
  
  def kid_logos
    if params[:id].blank?
      @user_kids = @user.user_kids
      @user_kid1 = @user_kids[0] if @user_kids.length >= 1
      @user_kid2 = @user_kids[1] if @user_kids.length >= 2
      @user_kid3 = @user_kids[2] if @user_kids.length >= 3
    else
      @user_kid = UserKid.find(params[:id]) 
    end
  end
  
  def update_kid_logo
    if params[:user_kid].blank? or params[:user_kid][:logo].blank?
      redirect_to :action=>'kid_logos' and return false
    end
    @user_kid = UserKid.find(params[:id]) 
    @user_kid.logo = params[:user_kid][:logo]
    @user_kid.save(:validate=>false)
    redirect_to :action=>'kid_logos',:id=>@user_kid.id,:cropper=>true 
  end
  
  def update_kid_logo_cropper
    @user_kid = UserKid.find(params[:id]) 
    MamashaiTools::ImageUtil.update_logos(@user_kid,params[:logo_left],params[:logo_top],params[:logo_size],[140,75,30])
    redirect_to :action=>'kid_logos',:success=>true 
  end
  
  ################ skin ###################
  
  def update_skin
    @user.skin = params[:id]
    @user.save(validate=>false)
    redirect_to :action=>'skin',:success=>true 
  end
  
  ################ notify ##################
  
  def notify
    @user_profile = @user.user_profile
  end
  
  def update_notify
    notify_ignores = params[:notify_ignores].collect{|m| m[0] if m[1]!='1'}.compact
    user_profile = @user.user_profile 
    user_profile.notify_ignores = notify_ignores.join('|')
    user_profile.save 
    redirect_to :action=>'notify',:success=>true 
  end
  
  def upload_skin
    if params[:skin] && params[:skin].to_i > 0
      @user.skin = params[:skin]
      @user.my_skin = nil
      @user.save(:validate=>false)
    end
    
    if params[:user] && params[:user][:my_skin]
      @user.my_skin = params[:user][:my_skin] 
      #@user.skin = nil
      @user.save(:validate=>false)
    end 
    
    @user.user_profile.content = params[:wenzi]
    @user.user_profile.save
    
    redirect_to :action=>"skin", :success=>true 
  end
  
  def delete_my_skin
    @user.my_skin = nil
    @user.save(:validate=>false)
    redirect_to :action=>"skin"
  end
  
  def add_user_kid
    @user_kid1 = UserKid.new if params[:user_kid] == "1"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid1,:user_kid_obj=>'user_kid1'} and return if @user_kid1
    @user_kid2 = UserKid.new if params[:user_kid] == "2"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid2,:user_kid_obj=>'user_kid2'} and return if @user_kid2
    @user_kid3 = UserKid.new if params[:user_kid] == "3"
    render :partial=>'form_kids',:locals=>{:user_kid=>@user_kid3,:user_kid_obj=>'user_kid3'} and return if @user_kid3
  end

  def delete_kid
    kid = UserKid.find(params[:id])
    kid.destroy if kid.user_id == @user.id
    render :text=>"ok"
  end
end
