#require 'contactlist-client'
#require 'json'
require 'fileutils'

class FriendsController < ApplicationController 
  before_filter :need_login_user
  before_filter :get_follow_user_ids
  layout "space"
  
  def search
    params[:tp] = params[:tp] || "age"
    @search_user = User.new
    cond = ["users.id <> #{@user.id}"]
    cond << "users.tp = 2" if params[:tp] == "angle"
    cond << "users.tp = 3" if params[:tp] == "super"
    cond << "age_id = #{@user.age_id}" if params[:tp] == "age"
    cond << "industry_id = #{@user.industry_id}" if params[:tp] == "job"
    cond << "users.province_id = #{@user.province_id}" if params[:tp] == 'city' && @user.province_id
    cond << "user_kids.birthday = '#{@user.first_kid.birthday}'" if params[:tp] == "birthday" && @user.first_kid
    @hot_users = User.not_hide.normal.paginate :page=>params[:page], :per_page=>8, :conditions=>cond.join(' and '),
      :joins=>"left join user_kids on user_kids.user_id = users.id", :order=>"fans_users_count desc"
  end
  
  def index
    
  end
  
  def find
    render_time = Time.now
    @search_user = User.new(params[:search_user])
    @is_no_search = ( !@user.mms_level && (@search_user.name.blank? && @search_user.province_id.blank? && @search_user.industry_id.blank? && @search_user.kid_age.blank? && @search_user.kid_star.blank?) )
    find_time = Time.now
    @users = User.find_search_users(@user,@search_user,params) unless @is_no_search
  end
  
  def maybe
    find_params = {:page=>params[:page]}
    find_params = {:page=>params[:page],:age_id=>params[:age]} unless params[:age].blank?
    find_params = {:page=>params[:page],:star=>params[:star]} unless params[:star].blank?
    find_params = {:page=>params[:page],:gender=>params[:gender]} unless params[:gender].blank?
    params[:id] = 'birthyear' if params[:id].blank?
    @users = User.find_maybe_users(@user,params[:id],find_params) 
  end
  
  def orgs
    @users = User.org.paginate(:per_page => 25,:include=>[:first_kid,:province,:city,:user_profile],:page => params[:page],:order => "users.fans_users_count desc") 
  end
  
  def my
    @space_user = @user
    @follows = @user.follows.paginate(:page=>params[:page]||1,:conditions=>['is_fans=1'],:include=>[:province,:city,:last_post,:first_kid],:order=>"follow_users.id desc",:per_page=>25)
  end
  
  def invite
  end
  
  def send_invite_email
    if params[:invite].blank? or params[:invite][:emails].blank?
      render :action => "invite" and return false
    end
    params[:invite][:emails].split(';').each do |email|
      Mailer.deliver_email(Mailer.send_invite(@user,InviteCode.create_invite_code(email,@user)))
    end
    redirect_to :action=>'invite',:success=>true
  end
  
  def resend_invite_email
    invite_code = InviteCode.find(params[:id])
    Mailer.deliver_email(Mailer.send_invite(@user,invite_code))
    redirect_to :action=>'invite',:success=>true
  end
  
  def invite_dispatch
    unless params[:invite].nil?
      begin
        account = params[:invite][:account]
        account = "#{params[:invite][:account]}@#{params[:invite][:type]}" unless params[:invite][:type] == "msn"
        type = params[:invite][:type]
        type = params[:invite][:type].split(".")[0] unless params[:invite][:type] == "msn"
        @contacts = ContactList::Client.fetch(account, params[:invite][:password], type)
      rescue Exception => exc
        flash[:notice] = "1=>请正确输入信息!"
        redirect_to :back
      end
      session[:account] = account
      session[:password] = params[:invite][:password]
      session[:type] = type
      @invite_type = type
    else
      @contacts =  @contacts = ContactList::Client.fetch(session[:account], session[:password], session[:type])
      @invite_type = session[:type]
    end
  end
  
  def create_follow_user
    if params[:follow].blank?
      flash[:notice] = "1=>您的邮箱联系人尚未注册"
      redirect_to :action => :invite_dispatch
    else
      i = 0
      params[:follow][:frends].each do |key, value|
        email = params[:follow][:emails][key] if value == "1"
        next email if email.blank?
        i += 1 unless email.blank? 
        to_follow_user = User.find_by_email(params[:follow][:emails][key])
        FollowUser.create_follow_user(to_follow_user, @user) unless to_follow_user.nil?
      end
      if i == 0
        flash[:notice] = "1=>请选择需要关注的好友"
      else
        flash[:notice] = "2=>关注好友成功"
      end
      redirect_to :action => :invite_dispatch
    end
  end
  
  def send_invite
    if params[:invite].blank?
      flash[:notice] = "1=>您的邮箱没有联系人"
      redirect_to :action => :invite
    else
      if params[:invite][:frends].blank?
        flash[:notice] = "1=>请选择需要邀请的好友"
        redirect_to :action => :invite
      else
        i = 0
        emails = []
        params[:invite][:frends].each do |key, value|
          email = params[:invite][:emails][key] if value == "1"
          next email if email.blank?
          i += 1 unless email.blank?
          emails << email
        end
        if params[:invite][:type] == "msn"
          email_address = ""
          for email in emails
            InviteCode.create_invite_code(email,@user)
            email_address += "#{email};"
          end
          content = "好友#{@user.name}邀请你加入妈妈晒!"
          Dir.chdir(File.join(::Rails.root.to_s,"lib/msn"))
          `java SendMessenger #{session[:account]} #{session[:password]} #{content} #{email_address}`
        else
          for email in emails
            Mailer.create_send_invite(@user,InviteCode.create_invite_code(email,@user)).deliver
            #Mailer.deliver_email(Mailer.create_send_invite(@user,InviteCode.create_invite_code(email,@user)))
          end
        end
        if i == 0
          flash[:notice] = "1=>请选择需要邀请的好友"
        else
          flash[:notice] = "2=>已经给你的好友发送了邀请消息"
        end
        session[:account] = nil
        session[:password] = nil
        session[:type] = nil
        redirect_to :action => :invite
      end
    end
  end
  
  def find_user
    user = User.find_by_name(params[:id])
    if user
      redirect_to :controller=>'space',:action=>'user',:id=>user.encrypt_user_id
    else
      @search_user = User.new(:name=>params[:id])
      @users = User.find_search_users(@user,@search_user,params)
      render :action=>'users'
    end
  end
  
  def birthday
    cond = ["users.id <> #{@user.id}"]
    cond << "users.id in (#{(@user.follow_user_ids<<-1).join(',')})" if params[:tp] == "friend"
    
    today = Time.new
    date2 = today.beginning_of_week.since(7.days)
    date3 = today.beginning_of_week.since(14.days)
    if params[:day] == "today" || !params[:day]
      cond << "(month(birthday)*100+day(birthday)) = #{rank(today)}"
    elsif params[:day] == "week1"
      cond << "(month(birthday)*100+day(birthday)) > #{rank(today)} and (month(birthday)*100+day(birthday)) < #{rank(date2)}"
    elsif params[:day] == "week2"
      cond << "(month(birthday)*100+day(birthday)) >= #{rank(date2)} and (month(birthday)*100+day(birthday)) < #{rank(date3)}"
    end
    @mama_users = User.find(:all, :conditions=>cond.join(' and '), :limit=>10, :order=>"rand()")
    @kid_users = User.find(:all, :conditions=>cond.join(' and ').gsub("birthday", "user_kids.birthday"), :limit=>10, :order=>"rand()", :joins=>"left join user_kids on user_kids.id = users.first_kid_id")
    
    if @user.birthday
      @me_sames = User.find(:all, :conditions=>"users.id <> #{@user.id} and user_kids.name is not null and (month(user_kids.birthday)*100+day(user_kids.birthday)) = #{rank(@user.birthday)}", :limit=>6, :joins=>"left join user_kids on user_kids.id = users.first_kid_id", :order=>"rand()")
    else
      @me_sames = []
    end
    
    if @user.first_kid && @user.first_kid.birthday
      @kid_sames = User.find(:all, :conditions=>"users.id <> #{@user.id} and user_kids.name is not null and (month(user_kids.birthday)*100+day(user_kids.birthday)) = #{rank(@user.first_kid.birthday)}", :limit=>6, :joins=>"left join user_kids on user_kids.id = users.first_kid_id", :order=>"rand()") if @user.first_kid
    else
      @kid_sames = []
    end
    render :layout => 'default2'
  end
  
private
  def rank(date)
    date.month * 100 + date.day
  end
  
end
