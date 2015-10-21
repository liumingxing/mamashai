require "sina_weibo"
require 'net/http'
require 'uri'
#require 'weibo2'
class Api::AccountController < Api::ApplicationController
  before_filter :authenticate!, :except=>[:get_location, :signup, :login, :callback, :sina, :tencent, :tencent_callback, :sina_mobile, :sina_mobile_callback, :tencent_mobile, :tencent_mobile_callback, :baby_calendar_mobile, :baby_calendar_mobile_callback, :taobao_mobile, :taobao_mobile_callback, :qzone_mobile, :qzone_mobile_callback, :taobao_bind, :login_by_weixin]
  
  #用户上传地址
  def upload_location
    old_province_id = @user.province_id
    old_city_id     = @user.city_id
    json = ActiveSupport::JSON.decode(params[:json])
    addr_json = json['geos'][0]
    @user.longitude = addr_json['longitude']
    @user.latitude  = addr_json['latitude']
    @user.location  = addr_json['address']

    province = Province.find_by_weibo_code("001%03d" % addr_json['province'])
    if province.post_code.to_s.size >=3  #直辖市
      @user.province_id = province.id
      district = City.find_by_name(addr_json['district_name'])
      if district
        @user.city_id = district.id
        UserLocation.set_location(@user.id, district.province_id, district.id)
      end
    else
      city = City.find_by_post_code(addr_json['city'])
      if city
        @user.city_id = city.id
        @user.province_id = city.province_id

        UserLocation.set_location(@user.id, city.province_id, city.id)
      end
    end
    
    @user.save
    UserInfo.set_info(@user.id, {:address_json=>params[:json]})

    result = {:user_id=>@user.id}
    result[:province_id] = @user.province.id if @user.province
    result[:province_name] = @user.province.name if @user.province
    result[:city_id] = @user.city.id if @user.city
    result[:city_name] = @user.city.name if @user.city
    render :json=>result
  end

  def get_location
    json = ActiveSupport::JSON.decode(params[:json])
    addr_json = json['geos'][0]
    result = {}
    province = Province.find_by_post_code(addr_json['city'])
    if province #直辖市
      result[:province_id] = province.id
      result[:province_name] = province.name
      district = City.find_by_name(addr_json['district_name'])
      if district
        result[:city_id] = district.id
        result[:city_name] = district.name
      end
    else
      city = City.find_by_post_code(addr_json['city'])
      if city
        result[:province_id]    = city.province.id
        result[:province_name]  = city.province.name
        result[:city_id]        = city.id
        result[:city_name]      = city.name
      end
    end

    render :json=>result
  end

  #获得用户开放平台账号的绑定情况
  def get_binds
    bind_weixin = UserWeixin.first(:conditions=>"user_id = #{@user.id}") ? true : false
    bind_qq     = UserQzone.first(:conditions=>"user_id = #{@user.id} and tp = 1") ? true : false
    bind_weibo  = UserWeibo.first(:conditions=>"user_id = #{@user.id} and tp = 7") ? true : false
    bind_tencent= UserQq.first(:conditions=>"user_id = #{@user.id} and tp = 7") ? true : false
    bind_taobao = UserTaobao.first(:conditions=>"user_id = #{@user.id} and tp = 2") ? true : false

    render :json=>{:weixin=>bind_weixin, :qq=>bind_qq, :weibo=>bind_weibo, :tencent=>bind_tencent, :taobao=>bind_taobao}
  end

  #删除一个宝宝
  def delete_kid
    kid = UserKid.find_by_id(params[:kid_id])
    if kid && kid.user_id == @user.id
      kid.destroy
      render :text=>"ok"
    else
      render :text=>"error"
    end
  end

  # ==更新用户头像
  #   [路径]: account/update_profile_image
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/account/update_profile_image.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - image 必须为小于700K的有效的GIF, JPG图片. 如果图片大于500像素将按比例缩放。 (必选)
  #
  # ====示例
  #   curl -u "username:password" -H 'Expect:' -F image=@'test2.jpg;type=image/jpeg'
  #   "http://your.api.domain/account/update_profile_image.json?source=appkey"
  #
  # ====注意
  #   采用multipart/form-data编码方式提交，可以参考：
  # Form-based File Upload in HTML: http://www.ietf.org/rfc/rfc1867.txt
  #
  def update_profile_image
    @user.logo = params[:image]
    if @user.save(:validate=>false)
      @user.upload_to_aliyun
      render :text => @user.to_json
    else
      render :text => 'error'
    end
  end

  # ==更新当前登录用户在新浪微博上的基本信息
  #   [路径]: account/update_profile
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/account/update_profile.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - 下列参数必选其一，多选不限。
  # - name 昵称，不超过20个汉字
  # - gender  性别， m 表示男性，w 表示女性。
  # - province  省份代码，参考省份城市编码表
  # - city 城市代码，为空表示不指定具体城市。参考省份城市编码表
  # - description  个人描述。不超过160个汉字
  #
  # ====示例
  #   curl -u "username:password" -d "gender=m&name=openapi"
  #   "http://your.api.domain/account/update_profile.json?source=appkey"
  #
  # ====注意
  #   * 提交成功后，只有参与提交的参数所对应的信息项会被更新。未参与提交的信息项将保持原值不变。
  #   * 例如：只提交name和gender参数，则只对用户昵称和性别进行更新，用户的省份、城市以及个人描述保持原值不变。
  #
  def update_profile
    render :text=>@user.to_json and return if params[:name].blank? and params[:gender].blank? and params[:province].blank? and params[:city].blank? and params[:description].blank?
    if params[:name].present? && params[:name].size > 0 && @user.name != params[:name]
    	if User.find(:first, :conditions=>["name=?", params[:name]])
          render :text=>"error" and return
      end
    	@user.name = URI.decode(params[:name])
    end
    old_province_id = @user.province_id
    old_city_id     = @user.city_id

    @user.gender = params[:gender] if params[:gender].present? && params[:gender].size > 0
    @user.province_id = params[:province] if params[:province].present? && params[:province].size > 0
    @user.city_id = params[:city] if params[:city].present? && params[:city].size > 0
    
    if params[:description].present? && params[:description].size > 0
      if @user.org_profile.present?
        @user.org_profile.update_attribute(:content, params[:description])  
      else
        @user.user_profile.update_attribute(:content, params[:description])
      end
    end
    @user.make_rmmseg

    if @user.save(:validate=>false)
      render :json=>@user
    else
       render :text => 'error'
    end
  end
  
  # ==更新当前登录用户孩子资料
  #   [路径]: account/update_kid_profile
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/account/update_kid_profile.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - 下列参数必选其一，多选不限。
  # - name 孩子昵称，不超过20个汉字
  # - gender  性别， m 表示男性，w 表示女性。
  # - birthday  孩子生日/预产期
  # - description  孩子描述
  #
  # ====示例
  #   curl -u "username:password" -d "gender=m&name=openapi"
  #   "http://your.api.domain/account/update_kid_profile.json?source=appkey"
  #
  # ====注意
  #   * 提交成功后，只有参与提交的参数所对应的信息项会被更新。未参与提交的信息项将保持原值不变。
  #   * 例如：只提交name和gender参数，则只对用户昵称和性别进行更新，其他原值不变。
  #
  def update_kid_profile
    render :text=>'error' and return if params[:name].blank? and params[:gender].blank? and params[:birthday].blank? and params[:description].blank?
    if params[:id]        #更改已有宝宝的资料
      kid = UserKid.find_by_id(params[:id])
      render :text=>"error" and return if !kid || kid.user_id != @user.id
    else                  #新添加宝宝资料
      render :text=>"error" and return if !params[:name]
      kid = UserKid.find(:first, :conditions=>["user_id=? and name=?", @user.id, params[:name]])
      kid = UserKid.new(:user_id=>@user.id) if !kid
    end
    kid.logo = params[:logo] if params[:logo]
    kid.name = URI.decode(params[:name]) if params[:name] && params[:name].size > 0
    kid.gender = params[:gender] if params[:gender] && params[:gender].size > 0 && params[:gender] != "null"
    kid.birthday = params[:birthday] if params[:birthday] && params[:birthday].size > 0
    kid.content = params[:description] if params[:description] && params[:description].size > 0
    kid.gender = nil if params[:gender] == "null"
    kid.save
    if @user.user_kids_count == 0
        @user.user_kids_count = 1
        @user.first_kid_id = kid.id
        @user.save(:validate=>false)
    end
    kid.upload_to_aliyun
    render :json=>@user.to_json(:include=>{:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}})
    #render :json=>kid.to_json(:only=>UserKid.json_attrs, :methods=>UserKid.json_methods)
  end

	
  # ==登录接口
  #   [路径]: account/login
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/account/login.json
  #   [是否需要登录]： false
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - email 登录邮箱
  # - password  密码
  #
  # ====示例
  #   curl -u "username:password" -d "email=xxx&password=xxx"
  #   "http://your.api.domain/account/login.json?source=appkey"
  #
  # ====注意
  #   * 登录成功，返回用户信息，失败则返回error
  #
  def login
    user,login_user = User.check_login_user({:user=>{:email=>params[:email], :password=>params[:password]}},request.env["HTTP_X_REAL_IP"]||request.remote_ip)
    render :text=>"error" and return if user.errors.present?
    render :json => login_user.to_json(:methods=>[:user_profile])
  end
  
  
  # ==注册接口
  #   [路径]: account/signup
  #   [HTTP请求方式]: POST
  #   [URL]: http://your.api.domain/account/signup.json
  #   [是否需要登录]： false
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  # - email 登录邮箱
  # - name 用户昵称
  # - password  密码
  # - password_confirmation 密码确认
  #
  # ====示例
  #   curl -u "username:password" -d ""email=zlxx@163.com&name=abc&password=123456&password_confirmation=123456"
  #   "http://your.api.domain/account/signup.json?source=appkey"
  #
  # ====注意
  #   * 注册成功，返回用户信息
  #   * 失败则返回 error 数组 示例[['name', "该昵称已经存在，请更换其他昵称"],['email', "该邮箱已经注册，请更换邮箱注册"]]
  #
  def signup
    params[:user_signup] = {
      :email => params[:email],
      :name => URI.decode(params[:name]),
      :password => params[:password],
      :password_confirmation => params[:password_confirmation],
      :from => params[:from],
      :gender =>params[:gender]
    }
    
    @user_signup = User.create_user_signup(params,request.env["HTTP_X_REAL_IP"]||request.remote_ip) 
    
    if @user_signup.errors.present?
      errors = []
      @user_signup.errors.each{|n, m|
        errors << [n, m]
      }
      render :json=>errors
    else
      render :json => @user_signup
    end

    return

    render :json=>@user_signup.errors.to_a.to_json and return if @user_signup.errors.present?
    render :json => @user_signup
  end
  
  
  # ==绑定新浪微博
  #   [路径]: account/sina
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/account/sina.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  #
  # ====示例
  #   curl -u "username:password" 
  #   "http://your.api.domain/account/sina.json"
  #
  # ====注意
  #   * 访问该链接后，会跳转到Sina登陆页面(WAP页面)，获取到用户的Token,和TokenSecret,用户相关个人信息
  #   * 失败则返回 error
  #
  def sina
    begin
      token = Weibotoken.get('sina', params[:from])
      oauth = Weibo::OAuth.new(token.token, token.secret)
      
      request_token = oauth.consumer.get_request_token
      oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/api/account/callback?user_id=#{params[:id]}&from=#{params[:from]}&rtoken=#{request_token.token}&rsecret=#{request_token.secret}&backurl=#{params[:callback]}")
      redirect_to "#{request_token.authorize_url}&oauth_callback=#{oauth_callback}"
    rescue Exception=>err
      logger.info err
      redirect_to "http://127.0.0.1:1980/app/Iphone/index?msg=登陆失败，请重试"
    end
  end
  
  def callback
    begin
      token = Weibotoken.get('sina', params[:from])
      oauth = Weibo::OAuth.new(token.token, token.secret)
      oauth.authorize_from_request(params[:rtoken], params[:rsecret], params[:oauth_verifier])
      sina_user = Weibo::Base.new(oauth).verify_credentials
    rescue Exception=>err
      logger.info err
      redirect_to "http://127.0.0.1:1980/app/Iphone/index?msg=登陆失败，请重试" and return
    end
    
    user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{sina_user.id}' and tp = #{token.tp}")
    if user_weibo && user_weibo.user  #绑定过
      user = user_weibo.user
    else            #没绑定过
      if params[:user_id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(params[:user_id])
        if user
          UserWeibo.delete_all("access_id = '#{sina_user.id}' and tp = #{token.tp}") if sina_user.present?
          UserWeibo.create(:user_id=>params[:user_id], :tp=>token.tp, :access_id=>sina_user.id, :access_token=>oauth.access_token.token, :access_secret=>oauth.access_token.secret)
        else
          redirect_to params[:backurl], :user=>"error"
          return
        end
      else                              #没传入用户，注册
        user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{sina_user.id}'")
        if user_weibo  #是妈妈晒用户，但绑定的是其他key
          UserWeibo.create(:user_id=>user_weibo.user_id, :tp=>token.tp, :access_id=>user_weibo.access_id, :access_token=>oauth.access_token.token, :access_secret=>oauth.access_token.secret)
          user = user_weibo.user
        else
          user        = User.find_by_email(sina_user["name"])
          if !user                        #有重名
            user        = User.new
            user.gender = sina_user["gender"]=='m' ? 'm' : 'w'
            user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
            user.email  = sina_user["name"]
            user.password = "mamashai"
            user.is_verify = true
            user.name   = sina_user["name"]
            user.logo   = open(sina_user["profile_image_url"]) if sina_user["profile_image_url"].to_s.size > 0 
            user.from   = params[:from]
            user.save
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
          end
          UserWeibo.create(:user_id=>user.id, :tp=>token.tp, :access_id=>sina_user.id, :access_token=>oauth.access_token.token, :access_secret=>oauth.access_token.secret)
        end        
      end
      
      #render :json=>user
    end
    
    if params[:backurl] && params[:backurl].index('?')
      redirect_to URI.escape("#{params[:backurl]}&user=#{user.to_json}")
    else
      redirect_to URI.escape("#{params[:backurl]}?user=#{user.to_json}")
    end
    
    session[:backurl] = nil
  end
  
  def tencent
    begin
      token = Weibotoken.get('qq', params[:from])
      consumer = OAuth::Consumer.new(token.token, token.secret, CONSUMER_OPTIONS)
      rand = rand(100000)
      request_token = consumer.get_request_token(:oauth_callback => "http://#{request.env["HTTP_HOST"]}/api/account/tencent_callback?user_id=#{params[:id]}&rand=#{rand}&from=#{params[:from]}&backurl=#{params[:callback]}")
      
      SessionTencent.create(:rand=>rand, :token=>request_token.token, :secret=>request_token.secret)
      
      redirect_to request_token.authorize_url
    rescue Exception=>err
      logger.info err
      redirect_to "http://127.0.0.1:1980/app/Iphone/index?msg=登陆失败，请重试"
    end
  end

  #已经废除
  def tencent_callback
    begin
      token = Weibotoken.get('qq', params[:from])
      consumer = OAuth::Consumer.new(token.token, token.secret, CONSUMER_OPTIONS)
      
      session_token = SessionTencent.find_by_rand(params[:rand])
      redirect_to "http://127.0.0.1:1980/app/Iphone/index?msg=登陆失败，请重试" and return if !session_token
      
      tencent_token, tencent_secret = session_token.token, session_token.secret
      request_token = ::OAuth::RequestToken.new(consumer, tencent_token, tencent_secret)
      access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
      tencent_user = ActiveSupport::JSON.decode(access_token.get("http://open.t.qq.com/api/user/info?format=json").body)
      session_token.destroy
    rescue Exception => err
      logger.info err
      redirect_to "http://127.0.0.1:1980/app/Iphone/index?msg=登陆失败，请重试" and return
    end
    
    user_qq = UserQq.find(:first, :conditions=>"openid = '#{tencent_user['data']['name']}' and tp = #{token.tp}")
    if user_qq && user_qq.user  #绑定过
      user = user_qq.user
    else            #没绑定过
      if params[:user_id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(params[:user_id])
        if user
          UserQq.delete_all("openid = '#{tencent_user['data']['name']}' and tp = #{token.tp}") if tencent_user.present?
          UserQq.create(:user_id=>params[:user_id], :openid=>tencent_user['data']['name'], :tp=>token.tp, :access_token=>access_token.token, :access_secret=>access_token.secret)
        else
          redirect_to params[:backurl], :user=>"error"
          return
        end
      else                              #没传入用户，注册
          user        = User.find_by_email(tencent_user["data"]["nick"] + "_tencent")
          if !user                        #没有重名
            user        = User.new
            user.gender = tencent_user['data']['sex'].to_s == "1" ? 'm' : 'w'
            user.email  = tencent_user['data']['name']+ "_tencent"
            user.password = "mamashai"
            user.is_verify = true
            user.name   = User.find_by_name(tencent_user['data']["nick"]) ? tencent_user['data']["nick"] + "_" + tencent_user['data']['name'] : tencent_user['data']["nick"] 
            
            file = open(tencent_user['data']["head"])
            user.logo = file
            user.save(:validate=>false)
            file.close if file
            File.delete(file.path) if file
            user.from   = params[:from] || "baby_calendar"
            user.save
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
          end
          UserQq.delete_all("openid = '#{tencent_user['data']['name']}' and tp = #{token.tp}")
          UserQq.create(:user_id=>user.id, :tp=>token.tp, :openid=>tencent_user['data']['name'], :access_token=>access_token.token, :access_secret=>access_token.secret)
      end
      
      #render :json=>user
    end
    
    if params[:backurl] && params[:backurl].index('?')
      redirect_to URI.escape("#{params[:backurl]}&user=#{user.to_json}")
    else
      redirect_to URI.escape("#{params[:backurl]}?user=#{user.to_json}")
    end
    
    session[:backurl] = nil
  end
  
  # ==js 验证用户是否存在(临时接口)
  #   [路径]: account/verify
  #   [HTTP请求方式]: GET
  #   [URL]: http://your.api.domain/account/verify.json
  #   [是否需要登录]： true
  #
  # ====参数
  # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
  #
  # ====示例
  #   curl -u "username:password" 
  #   "http://your.api.domain/account/verify.json"
  #
  # ====注意
  #   * 此接口用来辅助页面表单的验证信息的提交
  #   * 如果用户提交的username和password能通过验证，则返回ok
  #
  def verify
      render :text=>"ok"
  end

  def taobao_bind
    user_taobao = UserTaobao.find(:first, :conditions=>["taobao_nick = ?", params[:taobao_account]])
    if User.find_by_email(params[:email])
      flash[:notice] = "对不起此邮件地址已被占用"
      render :action=>"taobao_r" and return;
    end

    if user_taobao && user_taobao.user && params[:email].to_s.size > 0 && params[:password].to_s.size > 0
      user_taobao.user.email = params[:email]
      user_taobao.user.password =  MamashaiTools::TextUtil.md5(params[:password])
      user_taobao.user.save(:validate=>false)
    else
      flash[:notice] = "请检查您的输入"
      render :action=>"taobao_r" and return;
    end
    render :action=>"taobao_r_succ"
  end
  
  def taobao_mobile
    #render :action=>"taobao_r" and return;

    session[:token_from] = "baby_calendar"
    token = Weibotoken.get('taobao', session[:token_from])  
    session[:from_android] = params[:from_android]
    redirect_to "https://oauth.taobao.com/authorize?response_type=code&state=#{[session[:token_from], params[:id]].join(',')}&view=wap&client_id=#{token.token}&redirect_uri=http://www.mamashai.com/api/account/taobao_mobile_callback"
  end
  
  def taobao_mobile_callback
    if params[:access_denied]
      render :text=>"<h1>用户拒绝了授权</h1>" and return
    end

    arr = params[:state].split(',')
    token = Weibotoken.get('taobao', arr[0])
    #http = Net::HTTP.new("oauth.taobao.com", 443)
    #http.use_ssl = true
    #resp, data = http.post('https://oauth.taobao.com/token', "code=#{params[:code]}&grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=http://www.mamashai.com/api/account/taobao_mobile_callback")

    data = `curl --data 'code=#{params[:code]}&grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&redirect_uri=http://www.mamashai.com/api/account/taobao_mobile_callback' https://oauth.taobao.com/token`

    logger.info data
    logger.info('-------------------------------------------')
#logger.info(resp)
#logger.info(data)    
    
    json = ActiveSupport::JSON.decode(data)
    if params['error'] == 'invalid_client' || !json['taobao_user_nick']
      render :text=>"<h1>授权发生错误，请尝试其他登录方式</h1>" and return
    end
logger.info(json)
    uid = json['taobao_user_id']
    nick = URI.decode(json['taobao_user_nick'])
    
    params[:from_android] = session[:from_android]
    
   user_taobao = UserTaobao.find(:first, :conditions=>"taobao_id=#{uid} and tp = #{token.tp}", :order=>"id")
   if user_taobao && user_taobao.user           #绑定过
      if arr && arr.size > 1 && arr[1].length > 0     #传入了用户，绑定
        user = User.find_by_id(arr[1])
      else
        user = user_taobao.user
      end

      #刷新token
      UserTaobao.delete_all("taobao_id = '#{uid}' and tp = #{token.tp}") 
      UserTaobao.create(:user_id=>user.id, :tp=>token.tp, :taobao_id=>uid, :taobao_nick=>nick, :access_token=>json['access_token'], :expire_at=>Time.now.to_i + json['expires_in'].to_i, :refresh_token=>json['refresh_token'], :re_expire_at=>Time.new.to_i + json['re_expires_in'].to_i)
   else                                         #没绑定过
      if arr && arr.size > 1 && arr[1].length > 0     #传入了用户，绑定
        user = User.find_by_id(arr[1])
        if !user
          render :text=>"对不起，发生错误" and return
        end
      else                                      #没传入用户，注册
        user_taobao = UserTaobao.find(:first, :conditions=>"taobao_id = '#{uid}'")
        if user_taobao                          #是妈妈晒用户，但绑定的是其他key
          user = user_taobao.user
        else
            ####todo 获取用户性别，区域
            
            user        = User.new
            #user.gender = sina_user["gender"]=='m' ? 'm' : 'w'
            #user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
            user.email  = URI.decode(json["taobao_user_nick"] + "_taobao")
            user.password = "mamashai"
            user.is_verify = true
            user.name   = URI.decode(User.find_by_name(json["taobao_user_nick"]) ? json["taobao_user_nick"] + "_taobao" : json["taobao_user_nick"]) 
            user.from   = 'taobao' + token.from_str
            user.save
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
          
        end        
      end
    end
    
    UserTaobao.delete_all("taobao_id = '#{uid}' and tp = #{token.tp}") 
    UserTaobao.create(:user_id=>user.id, :tp=>token.tp, :taobao_id=>uid, :taobao_nick=>URI.decode(json['taobao_user_nick']), :access_token=>json['access_token'], :expire_at=>Time.now.to_i + json['expires_in'].to_i, :refresh_token=>json['refresh_token'], :re_expire_at=>Time.new.to_i + json['re_expires_in'].to_i)
    
    @token = json['access_token']
    @secret = ""
    @expire = Time.now.to_i + json['expires_in'].to_i
    
    @user = user
    render :action=>"baby_calendar_mobile_callback", :layout=>false
  end
  
  def baby_calendar_mobile
    if params[:id]
       session[:user_id] = params[:id]
    else
       session[:user_id] = nil
    end
    session[:token_from] = params[:from] || 'baby_calendar'
    session[:from_android] = params[:from_android]
    token = Weibotoken.get('sina', session[:token_from])	
    redirect_to "https://api.weibo.com/oauth2/authorize?display=mobile&response_type=code&client_id=#{token.token}&redirect_uri=http%3A%2F%2Fwww.mamashai.com%2Fapi%2Faccount%2Fbaby_calendar_mobile_callback"
  end
 
  def baby_calendar_mobile_callback
   session[:token_from] = session[:token_from] || 'baby_calendar'
   params[:from_android] = session[:from_android]
   token = Weibotoken.get('sina', session[:token_from])
   text = `curl -F 'a=b' 'https://api.weibo.com/oauth2/access_token?client_id=#{token.token}&client_secret=#{token.secret}&grant_type=authorization_code&redirect_uri=http%3A%2F%2Fwww.mamashai.com%2Fapi%2Faccount%2Fbaby_calendar_mobile_callback&code=#{params[:code]}'`
   json = ActiveSupport::JSON.decode(text)
   logger.info json
   if json['error_code']     #出错
     render :text=>"对不起，授权出错" and return;
   end
   
   uid = json['uid']
   access_token = json['access_token']
   expire_at = json['expires_in'].to_i.seconds.from_now
   
   token = Weibotoken.get('sina', session[:token_from])
   text = `curl 'https://api.weibo.com/2/account/get_uid.json?source=3584196665&access_token=#{access_token}'`
   logger.info text
   #text = `curl 'https://api.weibo.com/2/account/profile/basic.json?source=3584196665&access_token=#{access_token}'`
   logger.info "curl 'https://api.weibo.com/2/users/show.json?uid=#{uid}source=3584196665&access_token=#{access_token}'"
   text = `curl 'https://api.weibo.com/2/users/show.json?uid=#{uid}&source=3584196665&access_token=#{access_token}'`
   sina_user = ActiveSupport::JSON.decode(text)
   logger.info sina_user
   user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{uid}' and tp = #{token.tp}")
   if user_weibo && user_weibo.user  #绑定过
      user = user_weibo.user
   else            #没绑定过
      if session[:user_id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:user_id])
        if !user
          render :text=>"error" and return
        end
      else                              #没传入用户，注册
        user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{uid}'")
        if user_weibo  #是妈妈晒用户，但绑定的是其他key
          UserWeibo.create(:user_id=>user_weibo.user_id, :tp=>token.tp, :access_id=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
          user = user_weibo.user
        else
          user        = User.find_by_email(sina_user["name"] + "_weibo")
          if !user                        #有重名
            user        = User.new
            user.gender = sina_user["gender"]=='m' ? 'm' : 'w'
            user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
            user.email  = sina_user["name"] + "_weibo"
            user.password = "mamashai"
            user.is_verify = true
            user.name   = User.find_by_name(sina_user["name"]) ? sina_user["name"] + "_weibo" : sina_user["name"] 
            user.logo   = open(sina_user["avatar_large"]) if sina_user["avatar_large"].to_s.size > 0 
            user.from   = 'baby_calendar'
            user.save
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
          end
        end        
      end
    end
    
    UserWeibo.delete_all("access_id = '#{uid}' and tp = #{token.tp}") 
    UserWeibo.create(:user_id=>user.id, :tp=>token.tp, :access_id=>uid, :access_token=>access_token, :expire_at=>expire_at.to_i)
    
    @token = access_token
    @secret = ""
    @expire = expire_at.to_i
    
    @user = user
    render :layout=>false   
 end
  
  def sina_mobile
    token = Weibotoken.get('sina', params[:from])
    oauth = Weibo::OAuth.new(token.token, token.secret)
      
    request_token = oauth.consumer.get_request_token
    oauth_callback = CGI::escape("http://#{request.env["HTTP_HOST"]}/api/account/sina_mobile_callback?user_id=#{params[:user_id]}&rtoken=#{request_token.token}&rsecret=#{request_token.secret}")
    redirect_to "#{request_token.authorize_url}&oauth_callback=#{oauth_callback}&from=sina_mobile"
  end
  
  def sina_mobile_callback
    begin
      token = Weibotoken.get('sina', params[:from])
      @oauth = Weibo::OAuth.new(token.token, token.secret)
      @oauth.authorize_from_request(params[:rtoken], params[:rsecret], params[:oauth_verifier])
      sina_user = Weibo::Base.new(@oauth).verify_credentials
    rescue Exception => err
      logger.info err
      render :text=>err
      return
    end
      
    user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{sina_user.id}' and tp = #{token.tp}")
    if user_weibo && user_weibo.user  #绑定过
      user = user_weibo.user
    else            #没绑定过
      if params[:user_id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(params[:user_id])
        if user
          UserWeibo.delete_all("access_id = '#{sina_user.id}' and tp = #{token.tp}") if sina_user.present?
          UserWeibo.create(:user_id=>params[:user_id], :tp=>token.tp, :access_id=>sina_user.id, :access_token=>@oauth.access_token.token, :access_secret=>@oauth.access_token.secret)
        else
          render :text=>"error" and return
        end
      else                              #没传入用户，注册
        user_weibo = UserWeibo.find(:first, :conditions=>"access_id = '#{sina_user.id}'")
        if user_weibo  #是妈妈晒用户，但绑定的是其他key
          UserWeibo.create(:user_id=>user_weibo.user_id, :tp=>token.tp, :access_id=>user_weibo.access_id, :access_token=>@oauth.access_token.token, :access_secret=>@oauth.access_token.secret)
          user = user_weibo.user
        else
            user        = User.new
            user.gender = sina_user["gender"]=='m' ? 'm' : 'w'
            user.province_id, user.city_id = trans_city_by_name(sina_user["location"])
            user.email  = sina_user["name"] + "_weibo"
            user.password = "mamashai"
            user.is_verify = true
            user.name   = User.find_by_name(sina_user["name"]) ? sina_user["name"] + "_weibo" : sina_user["name"]
            user.logo   = open(sina_user["profile_image_url"]) if sina_user["profile_image_url"].to_s.size > 0 
            user.from   = params[:from]||'iphone'
            user.save
            UserProfile.create(:user_id => user.id, :score_actions=>'') 
          
            UserWeibo.create(:user_id=>user.id, :tp=>token.tp, :access_id=>sina_user.id, :access_token=>@oauth.access_token.token, :access_secret=>@oauth.access_token.secret)
        end        
      end
      
    end
    
    @access_token = @oauth.access_token
    @user = user
    render :layout=>false
  end
  
  def tencent_mobile
    session[:user_id] = params[:id] if params[:id]
    session[:token_from] = params[:from]||"baby_calendar"
    session[:origin_url] = params[:origin_url]
    session[:from_android] = params[:from_android]

    token = Weibotoken.get('qq', 'baby_calendar')  
    oauth_callback = CGI::escape("http://www.mamashai.com/api/account/tencent_mobile_callback")
    redirect_to "https://open.t.qq.com/cgi-bin/oauth2/authorize?response_type=code&client_id=#{token.token}&redirect_uri=#{oauth_callback}"
    return;
  end
  
  def tencent_mobile_callback
    session[:token_from] = session[:token_from]||"baby_calendar"
    token = Weibotoken.get('qq', "baby_calendar")
    oauth_callback = CGI::escape("http://www.mamashai.com/api/account/tencent_mobile_callback")
    text = `curl -F 'a=b' -k 'https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=#{token.token}&client_secret=#{token.secret}&grant_type=authorization_code&redirect_uri=#{oauth_callback}&code=#{params[:code]}'`

    params[:from_android] = session[:from_android]

    begin
      res_hash = {}
      text.split("&").each{|pa|res_hash[pa.split('=')[0]] = pa.split('=')[1]}
      p res_hash

      text = `curl -k 'https://open.t.qq.com/api/user/info?format=json&oauth_consumer_key=#{token.token}&access_token=#{res_hash['access_token']}&openid=#{res_hash['openid']}&oauth_version=2.a&scope=all'`

      tencent_user = ActiveSupport::JSON.decode(text)
      p tencent_user
    rescue Exception => err
      logger.info err
      render :text=>"发生错误" and return
    end
    
    user_qq = UserQq.find(:first, :conditions=>"(openid = '#{tencent_user['data']['name']}' or openid='#{res_hash['openid']}') and tp = #{token.tp}")
    if user_qq && user_qq.user  #绑定过
      user = user_qq.user
    else            #没绑定过
      if session[:user_id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(session[:user_id])
        if !user
          redirect_to params[:backurl], :user=>"error"
          return
        end
      else                              #没传入用户，注册
            user_qq = UserQq.find(:first, :conditions=>"openid='#{tencent_user['data']['name']}' or openid='#{res_hash['openid']}'")
            if user_qq    #但是绑定了其他的key
              user = user_qq.user
            else          #注册
              user        = User.new
              user.gender = tencent_user['data']['sex'].to_s == "1" ? 'm' : 'w'
              user.email  = tencent_user['data']['name'] + "_tencent"
              user.password = "mamashai"
              user.is_verify = true
              #user.name   = User.find_by_name(tencent_user['data']["nick"]) ? tencent_user['data']["nick"] + "_" + tencent_user['data']['name'] : tencent_user['data']["nick"]
              
              1.upto(1000) do |i|
              name = (tencent_user["data"]['nick']) + (i == 1 ? "" : i.to_s)
                if !User.find(:first, :conditions=>["name = ?", name])
                  user.name = name
                  break
                end
              end
	      file = open(tencent_user['data']["head"])
              user.logo = file
              user.save(:validate=>false)
              file.close if file
              File.delete(file.path) if file
              user.from   = params[:from] || "baby_calendar"
              user.save
              UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            end
      end
    end

    UserQq.delete_all("user_id = '#{user.id}' and tp = #{token.tp}")
    UserQq.create(:user_id=>user.id, :tp=>token.tp, :name=>tencent_user['data']['name'], :openid=>openid=res_hash['openid'], :access_token=>res_hash['access_token'], :expire_at=>res_hash["expires_in"].to_i.seconds.from_now)

    @token = res_hash['access_token']
    @secret = ''
    #@expire = Time.new.months_since(2).to_i
    @expire = res_hash["expires_in"].to_i + Time.new.to_i
    @user = user
    
    render :action=>"baby_calendar_mobile_callback" and return;


    if %w(baby_calendar lama_iphone lama_android).include?(params[:from])
      render :action=>"baby_calendar_mobile_callback"
    else
      render :action=>"sina_mobile_callback"
    end
    
  end

  def qzone_mobile
    token = Weibotoken.get('qzone', 'baby_calendar')
    session[:from_android] = params[:from_android]
    session[:user_id] = params[:id]
    redirect_to "https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=#{token.token}&state=#{params[:id]}&redirect_uri=http://www.mamashai.com/api/account/qzone_mobile_callback&display=mobile&scope=upload_pic,add_one_blog,get_info,add_t,add_pic_t,add_topic,add_share"
  end

  def qzone_mobile_callback
    logger.info params

    params[:from_android] = session[:from_android]
    token = Weibotoken.get('qzone', 'baby_calendar')
    text = `curl 'https://graph.qq.com/oauth2.0/token?grant_type=authorization_code&client_id=#{token.token}&client_secret=#{token.secret}&code=#{params[:code]}&state=#{params[:state]}&redirect_uri=http://www.mamashai.com/api/account/qzone_mobile_callback'`
    logger.info "---------~~~~~~~~~~~"
    logger.info text
    arr = text.split('&')
    tokens = {}
    for a in arr
      tokens[a.split('=')[0]] = a.split('=')[1]
    end
    logger.info tokens

    if tokens["access_token"].to_s.size == 0
      render :text=>"发生错误" and return
    end

    text = `curl https://graph.qq.com/oauth2.0/me?access_token=#{tokens['access_token']}`
    logger.info text
    text = text.scan(/{[\W\w]+}/)[0]
    open_ids = ActiveSupport::JSON.decode(text)

    #arr = text.split('&')
    #open_ids = {}
    #for a in arr
    #  open_ids[a.split('=')[0]] = a.split('=')[1]
    #end
    #logger.info open_ids
    #logger.info "-----------------"


    user_qzone = UserQzone.find(:first, :conditions=>"openid = '#{open_ids['openid']}'")
    if user_qzone && user_qzone.user  #绑定过
      if params[:state]                      #传入了用户
        user = User.find(params[:state])
      elsif !session[:uid]                                     #没有登录信息
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
      if params[:state].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(params[:state])
        if !user
          render :text=>"error" and return
        end
        UserQzone.create(:user_id=>user.id, :nick=>user.name, :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i) rescue nil
      else                              #没传入用户，注册
        user_qzone = User.find(:first, :conditions=>"email = '#{open_ids['openid']}'")
        if user_qzone  #是妈妈晒用户，但绑定的是其他key
          user = user_qzone
          UserQzone.create(:user_id=>user.id, :nick=>user.name, :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i) rescue nil
        else
            user        = User.new

            text = `curl 'https://graph.qq.com/user/get_simple_userinfo?access_token=#{tokens['access_token']}&oauth_consumer_key=#{token.token}&openid=#{open_ids['openid']}'`
            
            logger.info text

            begin
            json = JSON.parse(text)
            rescue
              json = {"gender"=>'w', "nickname"=>"QQ用户"}
            end
            p json

            
            user.gender = json["gender"]=='男' ? 'm' : 'w'
            #user.province_id, user.city_id = trans_city_by_name(json["location"])
            user.email  = open_ids['openid']
            user.password = "mamashai"
            user.is_verify = true
            1.upto(1000) do |i|
              name = (json["nickname"]||'qq用户') + (i == 1 ? "" : i.to_s)
              if !User.find(:first, :conditions=>["name = ?", name])
                user.name = name
                break
              end
            end
            user.email = user.name.to_s + "_qq" if !user.email 
            #user.logo   = open(json["figureurl_2"]) if json["figureurl_2"].to_s.size > 0 
            user.from   = 'qq绑定'
            user.save(:validate=>false)
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserQzone.delete_all("openid = '#{open_ids['openid']}' and tp = #{token.tp}") 
            UserQzone.create(:user_id=>user.id, :nick=>json["nickname"].to_s.force_encoding(::Encoding::UTF_8), :tp=>token.tp, :openid=>open_ids['openid'], :access_token=>tokens['access_token'], :expire_at=>Time.new.to_i + tokens['expires_in'].to_i)
        end        
      end
    end
    
    user_qzone = UserQzone.find(:first, :conditions=>"openid = '#{open_ids['openid']}'")
    @token = user_qzone.access_token
    @secret = user_qzone.access_secret
    @expire = user_qzone.expire_at
    @user = user
    render :action=>"baby_calendar_mobile_callback", :layout=>false
  end

  #修改用户密码
  def change_password
    @user.password = MamashaiTools::TextUtil.md5(params[:new_password])
    @user.save(:validate=>false)
    render :text=>"ok"
  end

  #用微信登陆
  def login_by_weixin
    if params[:url]
      params[:id] = params[:state]
      scans = params[:url].scan(/(\w+)\:\/\/oauth\?code=(\w+)/)
      params[:key] = scans[0][0]
      params[:code] = scans[0][1]
    end

    secrets = {"wx15a9f4829379b46f"=>"dd216fac8f9b7177ffc053d7ac9adcea", "wxf0f8850c3a525af7"=>"22277111109f6c60474db5a0f5ac917a", "wxc4e544191aa9121a"=>"9537f509d8363ef20921dc530fdfa6b5"}
    tps = {"wx15a9f4829379b46f"=>1, "wxf0f8850c3a525af7"=>2, "wxc4e544191aa9121a"=>3}
    #p "curl 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{params[:key]}&secret=#{secrets[params[:key]]}&code=#{params[:code]}&grant_type=authorization_code'"
    access_result = `curl 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{params[:key]}&secret=#{secrets[params[:key]]}&code=#{params[:code]}&grant_type=authorization_code'`
    access_json = ActiveSupport::JSON.decode(access_result)
    if access_json["errmsg"]
      render :json=>access_result and return
    end

    user_text = `curl 'https://api.weixin.qq.com/sns/userinfo?access_token=#{access_json['access_token']}&openid=#{access_json['openid']}'`
    user_json = ActiveSupport::JSON.decode(user_text)

    user_weixin = UserWeixin.find(:first, :conditions=>"unionid = '#{user_json["unionid"]}'")
    if user_weixin && user_weixin.user  #绑定过
      if params[:id] && params[:id].size > 0                      #传入了用户
        user = User.find(params[:id])
      else                                #没有登录信息
        user = user_weixin.user
      end

      UserWeixin.delete_all("unionid='#{user_json["unionid"]}'")
      UserWeixin.create(:user_id=>user.id, :nick=>user_json["nickname"], :sex=>user_json["sex"], :country=>user_json["country"], :province=>user_json["province"], :city=>user_json["city"], :head=>user_json["headimgurl"], :open_id=>access_json['openid'], :refresh_token=>access_json['refresh_token'], :tp=>tps[params[:key]], :scope=>access_json['scope'], :access_token=>access_json['access_token'], :expires_in=>access_json['expires_in'], :unionid=>user_json["unionid"])
    else            #没绑定过
      if params[:id].to_s.size > 0    #传入了用户，绑定
        user = User.find_by_id(params[:id])
        if !user
          render :text=>'"errcode":1,"errmsg":"绑定的用户不存在"' and return
        end

        UserWeixin.delete_all("unionid='#{user_json["unionid"]}'")
        UserWeixin.create(:user_id=>user.id, :nick=>user_json["nickname"], :sex=>user_json["sex"], :country=>user_json["country"], :province=>user_json["province"], :city=>user_json["city"], :head=>user_json["headimgurl"], :open_id=>access_json['openid'], :refresh_token=>access_json['refresh_token'], :tp=>tps[params[:key]], :scope=>access_json['scope'], :access_token=>access_json['access_token'], :expires_in=>access_json['expires_in'], :unionid=>user_json["unionid"])
      else                              #没传入用户，注册
        user = User.find(:first, :conditions=>"email = '#{access_json['openid']}'")
        if !user
            user        = User.new
            
            user.gender = user_json["sex"].to_s == "1" ? 'm' : 'w'
            user.email  = user_json["unionid"]
            if user_json["headimgurl"] && user_json["headimgurl"].size > 0
              file = open(user_json["headimgurl"])
              user.logo   = file
            end
            user.password = "mamashai"
            user.is_verify = true
            1.upto(1000) do |i|
              name = (user_json["nickname"]||'微信用户') + (i == 1 ? "" : i.to_s)
              if !User.find(:first, :conditions=>["name = ?", name])
                user.name = name
                break
              end
            end
            user.email = user.name.to_s + "_qq" if !user.email 

            if user_json["province"] && user_json["province"].size > 0
              province = Province.find_by_pinyin(user_json["province"])
              if province
                user.province_id = province.id
                if user_json["city"] && user_json["city"].size > 0
                  city = City.find_by_province_id_and_pinyin(province.id, user_json["city"])
                  user.city_id = city.id if city
                end
              end
            end
            
            user.from   = '微信'
            user.save(:validate=>false)
            file.close if file
            UserProfile.create(:user_id => user.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
            UserWeixin.delete_all("unionid='#{user_json["unionid"]}'")
            UserWeixin.create(:user_id=>user.id, :nick=>user_json["nickname"], :sex=>user_json["sex"], :country=>user_json["country"], :province=>user_json["province"], :city=>user_json["city"], :head=>user_json["headimgurl"], :open_id=>access_json['openid'], :refresh_token=>access_json['refresh_token'], :tp=>tps[params[:key]], :scope=>access_json['scope'], :access_token=>access_json['access_token'], :expires_in=>access_json['expires_in'], :unionid=>user_json["unionid"])
        end        
      end
    end
    render :json=>user
  end
  
private
  def trans_city_by_name(location)
   locations = location.split(' ')
   m_province_id = m_city_id = nil
   if locations.size > 0
     province = Province.find_by_name(locations[0])
     m_province_id = province.id if province
     city = City.find(:first, :conditions=>"province_id = #{m_province_id} and name like '#{locations[1]}%'") if m_province_id && locations.size > 1
     m_city_id = city.id if city
   end
   return m_province_id, m_city_id
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
end
