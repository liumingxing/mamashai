require 'uri'

class Api::ApplicationController < ApplicationController
    #before_filter :delete_nil_params
    after_filter :apicall_log, :except=>[:authenticate_app_source, :authenticate_app_source, :authenticate!, :public_timeline1, :public_timeline_count]
    before_filter :check_blacknames
    skip_before_filter :check_mms_user_login
    
    def check_blacknames
      black_ips = Rails.cache.fetch("blacknames", :expires_in=>10.minutes){
        Blackname.all().collect{|b| b.ip if b.ip}
      }
      if black_ips.include?(request.env["HTTP_X_REAL_IP"]||request.env["REMOTE_ADDR"])
        render :text => "visit denied by server" and return false;
      end
      
      return true;
    end
    
    def apicall_log
      api_call = Apicall.find(:first, :conditions=>"name='#{self.class.controller_name + "." + self.action_name}' and occur='#{Time.new.strftime('%Y-%m-%d')}'")  
      api_call = Apicall.new(:name=>self.class.controller_name + "." + self.action_name, :occur=>Time.new, :count=>0) if !api_call
      api_call.count += 1
      api_call.save rescue nil
    end
    
    def authenticate_app_source
        # render :text=>"app_key is not valid", :status=>401 and return unless "app_key is not valid"
    end

    def api_need_login_user
        render :text=>'need login', :status=>304 and return false unless @user
    end

    def authenticate!
        render :text=>"登录失败" and return false if !params[:username]
        request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{params[:username]}:#{params[:password]}") if params[:basic_http] = 1
        authenticate_or_request_with_http_basic do |username, password|
            if password.to_s == "mamashai" || password.to_s.size == 0 || %w(qzone sina baidu tencent taobao weixin).include?(params[:token_type])    #开放平台用户
              user = User.find_by_email(URI::decode(username)) || User.find_by_name(URI::decode(URI::decode(username)))
              if params[:token_type] == "weixin" && params[:token]
                if UserWeixin.find(:first, :conditions=>"user_id = #{user.id} and unionid='#{params[:username]}'")
                  @user = user
                  #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                  return
                end
              end

              if params[:token_type] == "sina" && params[:token]
                if UserWeibo.find(:first, :conditions=>"user_id = #{user.id} and access_token='#{params[:token]}'")
                  @user = user
                  #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                  return
                end
              end
              
              if params[:token_type] == "baidu" && params[:token]
                if UserBaidu.find(:first, :conditions=>"user_id = #{user.id} and token='#{params[:token]}'")
                  @user = user
                  #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                  return
                end
              end
             
              if params[:token_type] == "tencent"
                if UserQq.find(:first, :conditions=>"user_id = #{user.id}")
                  @user = user
                  #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                  return
                end 
	            end
	           
	            if params[:token_type] == "taobao"
	              if UserTaobao.find_by_access_token(params[:token])
	                @user = user
	                #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
	                return
	              end
	            end

              if params[:token_type] == "qzone"
                if UserQzone.find_by_access_token(params[:token])
                  @user = user
                  #user.last_login_at = Time.now
                  #user.last_login_ip = request.ip
                  #user.save(:validate=>false)
                  UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                  return
                end
              end
 
              if user #&& (user.user_weibo || user.user_baidu || user.email.to_s.index("@"))
                @user = user
                #@user.last_login_at = Time.now
                #@user.last_login_ip = request.ip
                #@user.save(:validate=>false)
                UserInfo.set_info(user.id, {:ip=>request.ip, :last_login_at=>Time.new})
              else
                render :text=>"登录失败" 
              end
            else
              if params[:tp].to_s == "2"
                user = User.find_by_email(URI::decode(params[:username]))
                render :text=>"登录失败" if !user
                @user = user if MamashaiTools::TextUtil.md5(MamashaiTools::TextUtil.md5(user.password)) == params[:password]
              else              
                @user,login_user = User.check_login_user({:user=>{:email=>URI::decode(username), :password=>password}},request.env["HTTP_X_REAL_IP"]||request.remote_ip)
                if @user.errors.blank?
                    #login_user.last_login_at = Time.now
                    #login_user.last_login_ip = request.ip
                    #login_user.save(:validate=>false)
                    UserInfo.set_info(@user.id, {:ip=>request.ip, :last_login_at=>Time.new})
                    @user = login_user
                else
                    # raise ActiveRecord::RecordNotFound.new("auth error")
                    render :text=>"登录失败"
                end
              end
            end
        end
    end
    
    def delete_nil_params
      params.delete_if{|k,v| v.blank?}
    end
    
    rescue_from Exception, :with => :deny_access if %w{production testing}.include?(RAILS_ENV)
        
    def deny_access(exception)
      logger.info exception
      log_exception(exception)
      common_error
      #render :text=>"error", :status => 400 and return false
    end

end
