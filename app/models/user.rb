# -*- coding: utf-8 -*-
require 'elasticsearch/model'

class User < ActiveRecord::Base
  after_create :add_default_logo
  
  after_create :add_mms_follow
  after_create :send_private_message
  before_create :make_rmmseg
  
  #after_create :create_sphinx_index

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_one :user_weibo
  has_one :user_qq
  
  belongs_to :province,:counter_cache => true
  belongs_to :city
  belongs_to :industry,:counter_cache => true
  has_one :user_signup
  has_one :user_profile,:dependent => :destroy
  has_one :org_profile,:dependent => :destroy
  belongs_to :age
  belongs_to :last_post, :class_name=> "Post",:foreign_key => "last_post_id"
  belongs_to :first_kid, :class_name=> "UserKid",:foreign_key => "first_kid_id"
  belongs_to :invite_user,:class_name=> "User",:foreign_key => "invite_user_id"
  belongs_to :invite_tuan_user,:class_name=> "User",:foreign_key => "invite_tuan_user_id"
  
  has_many :user_kids,:dependent => :delete_all
  has_many :user_blogs,:dependent => :delete_all
  has_many :user_books,:dependent => :delete_all
  has_many :posts,:dependent => :delete_all,:order=>'created_at desc'
  has_many :blog_categories,:dependent => :delete_all
  has_many :comments,:dependent => :delete_all
  has_many :favorite_posts,:dependent => :delete_all
  has_many :favorite_tags,:dependent => :delete_all
  has_many :visit_users,:dependent => :delete_all
  has_many :gift_gets,:dependent => :delete_all
  has_many :product_orders,:dependent => :delete_all
  has_many :score_events,:dependent => :delete_all
  has_many :invite_codes,:dependent => :delete_all
  has_many :user_rewards,:dependent => :delete_all
  
  has_many :spots
  has_many :article_goods, :dependent => :delete_all
  has_many :article_comments, :dependent => :delete_all
  has_many :articles, :dependent => :delete_all
  has_many :tuan_messages, :dependent => :destroy
  
  has_many :follow_users,:dependent => :delete_all
  has_many :fans_users, :class_name=> "FollowUser",:foreign_key => "follow_user_id",:dependent => :delete_all
  
  has_many :follows_groups,:dependent => :delete_all 
  has_many :fans_groups,:dependent => :delete_all
  
  has_many :follows, :through=>:follow_users,:class_name=>"User",:source=>:follow_user,
  :select=>"users.*,follow_users.follows_group_id,follow_users.is_fans,follow_users.nick_name,follow_users.remark "
  has_many :fans, :through=>:fans_users,:class_name=>"User",:source=>:user,
  :select=>"users.*,follow_users.fans_group_id,follow_users.is_fans,follow_users.fans_nick_name,follow_users.fans_remark "
  
  has_many :best_follow_users,:dependent => :delete_all
  has_many :best_follows, :through=>:best_follow_users,:class_name=>"User",:source=>:follow_user,:order=>'best_follow_users.id desc'
  
  has_many :org_branches ,:dependent => :delete_all
  has_many :column_books
  has_one :column_author
  has_and_belongs_to_many :subject, :join_table=>"subject_users"

  has_many :book_visits
  has_many :books, :through => :book_visits
  
  named_scope :org,:conditions=>"users.org_profile_id is not null and users.tp >= 0 and users.mms_level is null and users.logo is not null"
  named_scope :common,:conditions=>"users.org_profile_id is null and users.tp >= 0 and users.mms_level is null and users.id<>431 and users.logo is not null"
  named_scope :hot,:conditions=>"users.org_profile_id is null and users.tp >= 0 and users.mms_level is null and users.tp<>5 and users.id<>431 and users.logo is not null"
  named_scope :not_hide, :conditions=>"users.tp >= 0"
  named_scope :normal,:conditions=>"users.org_profile_id is null and users.tp >= 0 and users.tp < 4 and users.id<>431 and users.logo is not null",:order=>'posts_count desc'
  named_scope :sid, lambda { |sid|
    { :conditions => { :sid => sid } }
  }
  named_scope :spot_users,:conditions=>"users.tp >= 0 and users.logo is not null and spots_count>0",:order=>'users.created_at desc'
  
  has_many :user_score_statistics
  
  has_many :order_addresses,:order=>'updated_at desc'
  
  has_many :user_apps, :foreign_key => "user_id", :dependent => :destroy
  has_many :mms_apps, :through => :user_apps
  has_many :favorite_tuans,:dependent => :delete_all
  has_many :coupons,:dependent => :delete_all
  has_many :user_tags
  has_many :tags, :through => :user_tags
  has_many :lama_personal_templates
  
  #upload_column :logo ,:process => '450x450', :versions => {:thumb140 => "c140x140",:thumb30 => "c30x30", :thumb48 => "c48x48"}, :store_dir=>proc{|user, file| if File.directory?("public/upload/user_new/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}/logo") then "user_new/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}/logo" else "user_new/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}" end}
  #upload_column :my_skin, :process=>'1440x600', :versions=>{:thumb=>"c138x92", :thumb812=>"c812x251"}, :store_dir=>proc{|user, file| "user_new/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}/my_skin"}
  
  upload_column :logo ,:process => '450x450', :versions => {:thumb140 => "c140x140",:thumb30 => "c30x30", :thumb48 => "c48x48"}, :store_dir=>proc{|user, file| "user/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}/logo"}
  upload_column :my_skin, :process=>'1440x600', :versions=>{:thumb=>"c138x92", :thumb812=>"c812x251"}, :store_dir=>proc{|user, file| "user/#{user.created_at.strftime("%Y-%m-%d")}/#{user.id}/my_skin"}
  
  after_create :upload_to_aliyun

  attr_accessor :password_old,:password_confirmation,:kid_star,:kid_gender,:kid_age
  
  # tp -2:lock_user -1: hide_user 0:new_user 1:signup_user 2:angle_user 3:vip_user_or_org 4:hide_angle 5:secretary 10:admin_user 11:mamashai_user
  
  validates_presence_of :email,:message=>APP_CONFIG['error_signup_email']
  validates_uniqueness_of :email,:message=>APP_CONFIG['error_signup_email_exist'], :case_sensitive=>false
  #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message=>APP_CONFIG['error_signup_email_wrong']
  validates_presence_of :password,:message=>APP_CONFIG['error_signup_password']
  validates_confirmation_of :password,:on=>:create,:message=>APP_CONFIG['error_signup_password_wrong']
  validates_length_of :password,:on=>:create,:within => 6..20,:too_long=>APP_CONFIG['error_signup_password_length'],:too_short=>APP_CONFIG['error_signup_password_length']
  validates_format_of :password,:on=>:create,:with=>/^[a-zA-Z0-9]{6,20}$/,:message=>APP_CONFIG['error_signup_password_format'] 
  
  validates_presence_of :name,:message=>APP_CONFIG['error_user_name']
  validates_uniqueness_of :name,:message=>APP_CONFIG['error_user_name_exist'], :case_sensitive=>false
  validates_presence_of :user_kids_count,:message=>'请输入育儿状况'
  #  validates_format_of :name, :with => /^[\w-]+$/,:message=>APP_CONFIG['error_user_name_format']
  # validates_length_of :name,:within => 1..20,:too_long=>APP_CONFIG['error_user_name_length'],:too_short=>APP_CONFIG['error_user_name_length']
  #  validates_presence_of :gender,:message=>APP_CONFIG['error_user_gender']
  #  validates_presence_of :birthyear,:message=>APP_CONFIG['error_user_birthyear']
  #  validates_presence_of :birthday,:message=>APP_CONFIG['error_user_birthday']
  #validates_presence_of :province_id,:message=>APP_CONFIG['error_user_province'] 
  #validates_presence_of :city_id,:on => :update, :message=>APP_CONFIG['error_user_city']
  #  validates_presence_of :industry_id,:message=>APP_CONFIG['error_user_industry_id']
  #  validates_presence_of :tag_ids,:message=>APP_CONFIG['error_user_tag_ids']
  validates_length_of :domain,:within => 4..20,:too_long=>APP_CONFIG['error_user_domain_format'],:too_short=>APP_CONFIG['error_user_domain_format'],:allow_blank => true 
  validates_format_of :domain,:with=>/^[a-zA-Z0-9]{4,20}$/,:message=>APP_CONFIG['error_user_domain_format'] ,:allow_blank => true 
  # validates_format_of :mobile,:with => /^(13\d{9})$|^(15\d{9})$/,:allow_blank => true
  

  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)
    
    begin
      $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb140.filename}", File.open(self.logo.thumb140.path), {:content_type => self.logo.thumb140.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb30.filename}", File.open(self.logo.thumb30.path), {:content_type => self.logo.thumb30.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb48.filename}", File.open(self.logo.thumb48.path), {:content_type => self.logo.thumb48.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      
      if self.my_skin
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/my_skin/#{self.my_skin.filename}", File.open(self.my_skin.path), {:content_type => self.my_skin.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/my_skin/#{self.my_skin.thumb.filename}", File.open(self.my_skin.thumb.path), {:content_type => self.my_skin.thumb.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/my_skin/#{self.my_skin.thumb812.filename}", File.open(self.my_skin.thumb812.path), {:content_type => self.my_skin.thumb812.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      end
    rescue
        sleep(1)
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb140.filename}", File.open(self.logo.thumb140.path), {:content_type => self.logo.thumb140.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb30.filename}", File.open(self.logo.thumb30.path), {:content_type => self.logo.thumb30.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
        $connection.put("upload/user/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb48.filename}", File.open(self.logo.thumb48.path), {:content_type => self.logo.thumb48.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    end
  end

  #改变了省份和城市信息，刷新sphinx索引
  def update_post_sphinx_index
    offset = 0
    posts = Post.all(:conditions=>"user_id = #{self.id}", :limit=>1000, :offset=>offset, :order=>"id")
    while posts.size > 0
      for post in posts
        post.save
      end
      offset += 1000
      posts = Post.all(:conditions=>"user_id = #{self.id}", :limit=>1000, :offset=>offset, :order=>"id")
    end
  end

  def send_private_message
    code = CommandCode.new
    code.code = %Q!
      message = {}
      message[:message_post] = {}
      message[:message_post][:user_name] = User.find(#{self.id}).name
      message[:message_post][:content] = "亲，欢迎来到妈妈晒。我们是一个记录工具，帮助您更好的记录下孩子的成长历程，为将来存下一笔精神财富。我们也是一个社区，有大量的妈妈和准妈妈们在这里一块交流育儿经验。希望在育儿的道路上，我们能够一路同行。"
      message_post=MessagePost.create_message_post(message, User.find(431))
    !
    code.after = Time.now.since(10.seconds)
    code.status = 'wait'
    code.save
  end

  def make_rmmseg
    self.msn = RMMSeg::segment(self.name.to_s).join(' ')
  end
  
  def is_org?
    return false if self.org_profile.blank?  
    return true
  end
  
  def encrypt_user_id
    MamashaiTools::TextUtil.encrypt_user_id(self.id)
  end
  
  def http_user_url
    url =  "#{WEB_ROOT}/user/#{self.encrypt_user_id}" 
    url =  "#{WEB_ROOT}/u/#{self.domain}" if self.domain
    return url
  end
  
  def self.find_decrypt_user(str)
    self.find(MamashaiTools::TextUtil.decrypt_user_id(str))
  end
  
  def shopping_cart
    cart = ShoppingCart.find_by_user_id(self.id)
    return cart  if cart.present?
    return ShoppingCart.create(:user_id=>self.id,:shopping_items=>[] )
  end
  
  def is_get_reward_book?
    UserReward.find(:first,:conditions=>["reward = 'day_book' and user_id = ?",self.id]).present?
  end
  
  def is_can_create_event?
    self.tp == 3 or self.tp == 2 or self.tp == 10 or self.score > 100
  end
  
  def is_can_into_angle?
    self.tp == 2 or self.tp == 4 or self.tp == 10
  end
  
  #tp=4是妈妈晒的员工
  def is_can_delete_post?(post)
    post.user_id == self.id or self.tp==10 or self.tp == 4 # or (self.tp==2 and post.user.tp==1) or (self.tp==10 and post.user.tp==1)
  end
  
  def is_can_lock_user?(user)
    user.id != self.id and (user.tp == 0 or user.tp==1 or user.tp==-2) and (self.tp==2 or self.tp==10)
  end
  
  ###########################  attributes  ############################ 
  
  def first_spot
    Spot.find(:first,:conditions=>['user_id=?',self.id],:order=>'id desc')
  end
  
  def is_admin
    self.tp >=10
  end 
  
  def is_org
    self.org_profile_id.present?
  end
  
  def is_specail_users
    [100,102,105,106,107,115,262,292,440,302].include?(self.id)
  end
  
  def is_cc_users
    self.is_admin && self.mms_level && self.mms_level >= 2
  end
  
  def is_market_users
    [246].include?(self.id)
  end
  
  def is_vip_user
    self.tp == 2
  end
  
  
  def invited_success_users
    User.find(:all,:conditions=>['invite_user_id=?',self.id])
  end
  
  def is_super_admin
    self.id == 100 or self.id == 106 or self.id == 416
  end
  
  def job_title_str 
   ( self.job_title.blank?  ? '' : "#{self.company}#{self.job_title}" )
  end
  
  def name_str
    self.name.blank? ? self.email_name : self.name
  end
  
  def email_name
    self.email.split('@')[0]
  end
  
  def has_unread_infos
    MamashaiTools::ToolUtil.has_unread_infos(self)
  end 
  
  def follow_user_ids
    FollowUser.find(:all,:select=>'follow_user_id',:conditions=>['user_id=?',self.id]).collect{|u| u.follow_user_id}
  end
  
  def fans_user_ids
    FollowUser.find(:all,:select=>'user_id',:conditions=>['follow_user_id=?',self.id]).collect{|u| u.user_id}
  end

  def follow_user_remarks
    FollowUser.find(:all,:select=>'remark',:conditions=>["user_id=? and remark is not null and remark <> ''",self.id]).collect{|u| u.remark}.compact.uniq
  end
  
  def follow_user_fans_remarks
    FollowUser.find(:all,:select=>'fans_remark',:conditions=>["follow_user_id=? and fans_remark is not null and fans_remark <> ''",self.id]).collect{|u| u.fans_remark}.compact.uniq
  end

  def has_follow?(user_id)
    user = FollowUser.find(:first, :conditions=>['follow_user_id = ? and user_id= ?', user_id, self.id])
    return user ? true : false
  end

  def has_fan?(user_id)
    user = FollowUser.find(:first, :conditions=>['follow_user_id= ? and user_id = ?', self.id, user_id])
    return user ? true : false
  end
  
  def is_valid_password(password)
    self.password == MamashaiTools::TextUtil.md5(password)
  end
  
  def update_password(params)
    return self.errors.add(:password_old,APP_CONFIG['error_user_password_old']) unless self.is_valid_password(params[:user][:password_old])
    return self.errors.add(:password_confirmation,APP_CONFIG['error_signup_password_wrong']) unless params[:user][:password] == params[:user][:password_confirmation]
    self.update_attributes(params[:user]) 
    self.update_attributes(:password=>MamashaiTools::TextUtil.md5(params[:user][:password])) if self.errors.empty? 
  end 
  
  def update_user_domain(user_domain)
    user_domain = MamashaiTools::TextUtil.gsub_dirty_words(user_domain) unless user_domain.blank? 
    user_domain = MamashaiTools::TextUtil.gsub_site_words(user_domain) unless user_domain.blank? 
    return self.errors.add(:domain,APP_CONFIG['error_user_domain_format']) if user_domain.blank?
    return self.errors.add(:domain,APP_CONFIG['error_user_domain_exist']) if User.find_by_domain(user_domain)
    
    self.domain = user_domain
    self.save(:validate=>false)
  end
  
  def create_visit_user(visit_user)
    visit_users = self.visit_users
    return if visit_users.detect{|v| v.visit_user_id == visit_user.id }
    if visit_users.length >= 9
      visit_users[0].destroy
    end
    VisitUser.create(:visit_user_id=>visit_user.id,:user_id=>self.id)
  end
  
  ########################### action methods  ############################
  
  def self.mms_user_id
    431
  end
  
  def self.mms_vip_user_ids
    [102,431]
  end
  
  def self.auto_follow_vip_and_mms_users(add_user)
    ActiveRecord::Base.transaction do
      User.find(:all,:conditions=>['tp=2 or id in (?)',User.mms_vip_user_ids]).each do |vip_user| 
        FollowUser.create_follow_user(vip_user,add_user)
        FollowUser.create_follow_user(add_user,vip_user)
      end
    end
  end
  
  def self.hide_user(id)
    ActiveRecord::Base.transaction do
      user = User.find(id)
      user.tp=-1
      user.save(:validate=>false)
      user.follow_users.each do |follow_user|
        FollowUser.delete_follow_user(user,follow_user.follow_user)
      end
      FollowUser.find(:all,:conditions=>['follow_user_id=?',user.id]).each do |follow_user|
        FollowUser.delete_follow_user(follow_user.user,user)
      end
    end
  end
  
  def self.update_invite_user_score(user)
    invite_user = user.invite_user
    if invite_user 
      score_tp = 'be_invited'
      user_profile = user.user_profile
      return if user_profile.score_actions && user_profile.score_actions.index(score_tp)
      return unless user.logo && user.posts_count > 0 && UserProfile.is_finish_profile(user,user_profile)
      
      invite_user.unread_invited_count += 1
      invite_user.save(:validate=>false)
      
      user_profile.update_score_actions(score_tp)
    end
  end
  
  def self.gsub_user_name(user_name)
    user_name = MamashaiTools::TextUtil.gsub_dirty_words(user_name) unless user_name.blank? 
    user_name = MamashaiTools::TextUtil.gsub_site_words(user_name) unless user_name.blank? 
    user_name
  end
  
  def self.check_login_user(params,ip) 
    user = User.new(params[:user])
    user.email = user.email.strip if user.email
    if user.email.blank? or user.password.blank?
      user.errors.add(:email,APP_CONFIG['error_login_input']) 
      return user,nil 
    end
    login_user = User.find_by_email(user.email) || User.find_by_mobile(user.email)
    if login_user
      user.errors.add(:email,APP_CONFIG['error_login_user_wrong']) unless login_user.is_valid_password(user.password)
      login_user.last_login_at = Time.now
      login_user.last_login_ip = ip
      login_user.save(:validate=>false)
    else
      if UserSignup.find_by_email(user.email)
        user.errors.add(:email,APP_CONFIG['error_login_no_email_check'])
      else
        user.errors.add(:email,APP_CONFIG['error_login_user_wrong']) 
      end
    end
    
    return user,login_user
  end 
  
  def self.create_user_signup(params,ip) 
    begin
      user_signup = User.new(params[:user_signup]||params[:user])
    rescue
      user_signup = User.new 
      return user_signup
    end
    user_signup.email = user_signup.email.downcase.strip 
    return user_signup unless user_signup.save
    UserProfile.create(:user_id => user_signup.id, :uuid=>MamashaiTools::TextUtil.uuid, :score_actions=>'') 
    if user_signup.user_kids_count >= 0 and user_signup.birthday.present?
      user_signup.first_kid = UserKid.create(:user_id=>user_signup.id,:birthday=>user_signup.birthday) 
    end
    
    Age.update_user_age_id(user_signup)     
#    Mms::App.add_default_apps(user_signup)   
    Thread.new do
      Mailer.deliver_email(Mailer.send_signup(user_signup))
    end
    user_signup.password = MamashaiTools::TextUtil.md5(user_signup.password)
    user_signup.birthday = nil
    user_signup.last_login_ip = ip
    user_signup.save
    user_signup
  end
  
  ########################### limit ############################
  
  def self.find_hot_users(user)
    if user
      return User.common.find(:all,:limit=>9,:select=>'users.id,users.name,users.created_at,users.logo,users.tp,users.gender,users.domain',:conditions=>['users.id <> ? and users.tp >= 0 and users.tp<>2 and users.id<>431 and users.mms_level is null',user.id],:order=>'fans_users_count desc')
    else
      return User.common.find(:all,:limit=>9,:select=>'users.id,users.name,users.created_at,users.logo,users.tp,users.gender,users.domain',:conditions=>['users.tp >= 0 and users.tp<>2 and users.id<>431 and users.mms_level is null'],:order=>'fans_users_count desc')
    end
  end
  
  def self.find_vip_users
    select_str = 'users.id,users.name,users.created_at,users.remark,users.logo,users.tp,users.gender,users.domain'
    User.find(:all,:limit=>9,:select=>select_str,:conditions=>['users.tp = 2 and users.mms_level is null '],:order=>'fans_users_count desc')
  end
  
  def self.find_index_hot_users
    User.find(:all,:limit=>9,:select=>'users.id,users.name,users.created_at,users.logo,users.tp,users.gender,users.domain',:conditions=>['users.tp >= 0 and users.tp < 11'],:order=>'fans_users_count desc')
  end
  
  def self.find_not_follow_hot_users(user,follow_ids)
    return User.not_hide.hot.all(:limit=>9,:conditions=>['users.id not in (?) and users.posts_count > 50',follow_ids],:order=>'rand()') 
  end
  
  def self.find_similar_users(user,follow_ids)
    sqls = [] << User.send(:sanitize_sql,['users.tp >= 0 and users.tp < 5 and users.mms_level is null and users.logo is not null'])
    sqls << User.send(:sanitize_sql,["users.id not in (?) and posts_count > 5",follow_ids])
    if user.is_org
      sqls << User.send(:sanitize_sql,["users.org_profile_id is not null"])
    else
      sqls << User.send(:sanitize_sql,["users.tp <> 5 "])
      sqls << User.send(:sanitize_sql,["users.org_profile_id is null"])
    end
    sqls << User.send(:sanitize_sql,["(users.birthyear=? and users.province_id=?) or (users.birthyear=? and users.age_id=?) or (users.province_id=? and users.age_id=?)",user.birthyear,user.province_id,user.birthyear,user.age_id,user.province_id,user.age_id])
    User.find(:all,:limit=>9,:select=>'users.id,users.name,users.created_at, users.logo,users.tp,users.gender,users.domain',:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:order=>'rand()')
  end
  
  def self.find_last_visit_users(user)
    User.find(:all,:limit=>6,:select=>'users.id,users.created_at,first_kid_id, users.name,users.logo,users.tp,users.gender,users.domain',:conditions=>['visit_users.user_id=? and users.tp >= 0',user.id],:order=>'visit_users.id desc',:joins=>'inner join visit_users on visit_users.visit_user_id = users.id')
  end
  
  def self.find_last_birthday_users(user)
    today = Date.today
    rank= today.month * 100 + today.day
    users=User.not_hide.all :conditions=>"(month(users.birthday)*100+day(users.birthday)) >= #{rank} and users.id <> #{user.id}", :order=>"(month(users.birthday)*100+day(users.birthday)) asc",:limit=>16
    if users.size < 16
      limit = users.size.present? ? 16-users.size : 16
      users=users.concat(User.not_hide.all(:conditions=>"(month(users.birthday)*100+day(users.birthday)) <= #{rank} and users.id <> #{user.id}", :order=>"(month(users.birthday)*100+day(users.birthday)) asc",:limit=>limit))
    end
    return users
  end
  
  def self.find_last_kid_birthday_users(user)
    today = Date.today
    rank= today.month * 100 + today.day
    day_position = "(month(user_kids.birthday)*100+day(user_kids.birthday))"
    joins = " inner join user_kids on user_kids.id = users.first_kid_id"
    
    users=User.not_hide.all(:conditions=>" #{day_position} >= #{rank} and users.id <> #{user.id}  and user_kids.name is not null", :order=>"#{day_position} asc",:limit=>16,:joins=>joins)
    
    if users.size < 16
      limit = users.size.present? ? 16-users.size : 16
      users=users.concat(User.not_hide.all(:conditions=>"#{day_position} <= #{rank} and users.id <> #{user.id} and user_kids.name is not null", :order=>"#{day_position} asc",:limit=>limit,:joins=>joins))
    end
    return users
  end
  
  ########################### find ############################
  
  def self.find_search_users(user,search_user,params,select_str=nil)
    sqls = [] << User.send(:sanitize_sql,['users.id<>? and users.tp>=0',user.id])
    sqls << User.send(:sanitize_sql,["users.name like ? ","%#{search_user.name}%"]) unless search_user.name.blank?
    #sqls << User.send(:sanitize_sql,["users.gender = ?",search_user.gender]) unless search_user.gender.blank?
    sqls << User.send(:sanitize_sql,["users.birthyear = ?",search_user.birthyear]) unless search_user.birthyear.blank?
    sqls << User.send(:sanitize_sql,["users.province_id = ?",search_user.province_id]) unless search_user.province_id.blank?
    sqls << User.send(:sanitize_sql,["users.city_id = ?",search_user.city_id]) unless search_user.city_id.blank?
    sqls << User.send(:sanitize_sql,["users.industry_id = ?",search_user.industry_id]) unless search_user.industry_id.blank?
    sqls << User.send(:sanitize_sql,["users.age_id = ?",search_user.kid_age]) unless search_user.kid_age.blank?
    sqls << User.send(:sanitize_sql,["user_kids.gender = ?",search_user.kid_gender]) unless search_user.kid_gender.blank?
    sqls << User.send(:sanitize_sql,["user_kids.star = ?",search_user.kid_star]) unless search_user.kid_star.blank?
    if params[:is_org]=='1'
      sqls << User.send(:sanitize_sql,["users.org_profile_id is not null"])
    end
    if params[:is_org]=='0'
      sqls << User.send(:sanitize_sql,["users.org_profile_id is null"])
    end
    select_str = 'users.id,users.name,users.created_at,users.remark,users.gender,users.logo,users.tp,users.domain,users.fans_users_count,users.last_post_id,users.first_kid_id,users.province_id,users.city_id' unless select_str
    User.paginate(:per_page => params[:per_page]||25,:select=>select_str,:conditions=> sqls.collect{|c| "(#{c})"}.join(' AND ') ,:include=>[:first_kid,:province,:city,:user_profile],:page => params[:page]||1,:order => params[:order]||"users.id desc") 
  end
  
  def self.find_follow_users(user,params)
    order_str = "follow_users.id desc" 
    order_str = 'follow_users.id desc' if params[:tp]=='kid_age'
    order_str = 'follow_users.id desc' if params[:tp]=='remark'
    conditions = ['follow_users.user_id=? and users.name is not null',user.id]
    conditions = ['follow_users.user_id=? and users.age_id = ?',user.id,params[:age_id]] if params[:tp]=='kid_age' 
    conditions = ['follow_users.user_id=? and follow_users.remark = ?',user.id,params[:remark]] if params[:tp]=='remark' and !params[:remark].blank?
    conditions = ['follow_users.user_id=? and users.name like ?',user.id,"%#{params[:search_user][:name]}%"] if params[:search_user] and !params[:search_user][:name].blank?
    joins_str = 'inner join follow_users on follow_users.follow_user_id=users.id'
    select_str = 'users.id,users.name,users.created_at,users.remark,users.gender,users.email,users.logo,users.tp,users.domain,users.fans_users_count,users.last_post_id,users.first_kid_id,users.province_id,users.city_id,follow_users.is_fans as follow_users_count,follow_users.remark as tag_ids,follow_users.nick_name as age_ids'
    User.paginate(:per_page => 20,:select=>select_str,:joins=>joins_str,:conditions => conditions,:include=>[:last_post,:first_kid,:province,:city],:page => params[:page],:order =>order_str )
  end
  
  def self.find_fans_users(user,params)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_fans_count)
    order_str = "follow_users.id desc" 
    order_str = 'follow_users.id desc' if params[:tp]=='kid_age'
    order_str = 'follow_users.id desc' if params[:tp]=='remark'
    conditions = ['follow_users.follow_user_id=?',user.id]
    conditions = ['follow_users.follow_user_id=? and users.age_id = ?',user.id,params[:age_id]] if params[:tp]=='kid_age' 
    conditions = ['follow_users.follow_user_id=? and follow_users.fans_remark = ?',user.id,params[:remark]] if params[:tp]=='remark' and !params[:remark].blank?
    conditions = ['follow_users.follow_user_id=? and users.name like ?',user.id,"%#{params[:search_user][:name]}%"] if params[:search_user] and !params[:search_user][:name].blank?
    
    joins_str = 'inner join follow_users on follow_users.user_id=users.id'
    select_str = 'users.id,users.name,users.created_at,users.remark,users.gender,users.email,users.logo,users.tp,users.domain,users.fans_users_count,users.last_post_id,users.first_kid_id,users.province_id,users.city_id,follow_users.is_fans as follow_users_count,follow_users.fans_remark as tag_ids,follow_users.fans_nick_name as age_ids'
    User.paginate(:per_page => 25,:select=>select_str,:joins=>joins_str,:conditions => conditions,:include=>[:last_post,:first_kid,:province,:city],:page => params[:page],:order =>order_str ) 
  end 
  
  def self.find_maybe_users(user,tp,find_params)
    sqls = [] <<  User.send(:sanitize_sql,['users.id <> ? and users.tp>0 and users.org_profile_id is null and users.logo is not null ',user.id])
    sqls << User.send(:sanitize_sql,["users.tp <> 5 "])
    sqls << User.send(:sanitize_sql,['users.birthyear=?',user.birthyear]) if tp=='birthyear'
    sqls << User.send(:sanitize_sql,['users.province_id=?',user.province_id]) if tp=='province'
    sqls << User.send(:sanitize_sql,['users.industry_id=?',user.industry_id]) if tp=='industry'
    sqls << User.send(:sanitize_sql,['users.user_kids_count=0']) if tp=='no_kid'
    sqls << User.send(:sanitize_sql,['users.tag_ids like ?',"%#{user.tag_ids}%"]) if tp=='topic'
    sqls << User.send(:sanitize_sql,['users.age_id = ?',find_params[:age_id]]) if tp=='age'
    sqls << User.send(:sanitize_sql,['user_kids.star=?',find_params[:star]]) if tp=='cons'
    sqls << User.send(:sanitize_sql,['user_kids.gender=?',find_params[:gender]]) if tp=='gender'
    
    if find_params[:limit]
      select_str = 'users.id,users.name,users.remark,users.created_at,users.gender,users.logo,users.tp,users.domain'
      sqls << "logo is not null"
      sqls << "posts_count > 30"
      return User.find(:all,:limit => find_params[:limit],:select=>select_str,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:order => find_params[:order]) 
    else
      select_str = 'users.id,users.name,users.remark,users.created_at,users.gender,users.logo,users.tp,users.domain,users.fans_users_count,users.last_post_id,users.first_kid_id,users.province_id,users.city_id'
      return User.paginate(:per_page => 25,:select=>select_str,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>[:last_post,:first_kid,:province,:city],:page => find_params[:page],:order => "users.id desc") 
    end
  end
  
  def generate_sid
  #  self.sid=MamashaiTools::TextUtil.uuid   
  #  self.save(:validate=>false)
  #  return self.sid
  end
  
  def email_site
    MamashaiTools::TextUtil.email_site(self.email)
  end
  
  def self.reset_password(params)
    unless params[:user] or params[:user][:email]
      user.errors.add(:email,APP_CONFIG['error_signup_email'])
      return user
    end
    user = User.find_by_email(params[:user][:email])
    if user.blank?
      user = User.new
      user.errors.add(:email,APP_CONFIG['error_find_password_email'])
      return user
    end
    profile = user.user_profile
    reset_password = MamashaiTools::TextUtil.rand_8_str
    profile.update_attributes({:password_reset=>reset_password,:uuid=>MamashaiTools::TextUtil.uuid}) if profile
    return user
  end
  
  def self.find_by_uuid(uuid)
    User.find(:first,:conditions=>["user_profiles.uuid=?",uuid],:joins=>"left join user_profiles on user_profiles.user_id=users.id",:readonly=>false)
  end
  
  def self.confirm_reset_password_by_uuid(uuid)
    user = User.find_by_uuid(uuid)
    if user
      user.update_attributes(:password=>MamashaiTools::TextUtil.md5(user.user_profile.password_reset),:is_verify=>true)
    end
    user
  end
  
  def is_award
    Mms::AwardUser.count(:all,:conditions=>["user_id = ?",self.id]) > 0
  end
  
  
  ##############团购###################
  def paid_tuan?
    TuanOrder.count(:conditions=>["state in (?) and user_id =?",["has_paid","has_sent","has_sign_up","has_received"],self.id]) >0
  end
  
  def buy?(tuan=nil)
    return false unless tuan
    return true if OrderItem.last(:conditions=>["order_items.item_id=? and orders.user_id=? and orders.state in (?)",tuan.id,self.id,["has_paid","has_sent","has_sign_up","has_received"]],:joins=>"inner join orders on order_items.order_id=orders.id")
  end
  
   #判断是否为专栏作家
  def column_author?
    return ColumnAuthor.find_by_user_id(self.id) ? true : false
  end
  
  ######################################
  def same_kind_users
    conditions = []
    
    same_follow_users = FollowUser.find(:all, :conditions=>"follow_user_id in (#{(self.follow_ids[0,10]<<1).join(',')}) and user_id <> #{self.id}", :limit=>20, :order=>"id")
    conditions << "id in (#{(same_follow_users.collect{|u| u.user_id}<<0).join(',')})"
    conditions << "city_id = #{self.city_id}" if self.city_id
    conditions << "industry_id = #{self.industry_id}" if self.industry_id
    last_user = User.find(:first, :order=>"id desc")
    if conditions.size > 0
      User.find(:all, :conditions=>"(#{conditions.join(' or ')}) and id > #{rand(last_user.id)}", :limit=>6)
    else
      []
    end
  end
  
  
  ##############json########
  # ==json_attrs 输出字段
  # * id: 用户ID
  # * name: 微博昵称
  # * email: 邮箱
  # * gender: 性别,m--男，w--女,null--未知
  # * domain: 用户个性化URL
  # * score: 用户积分
  # * unread_fans_count: 未读新粉丝数目
  # * unread_comments_count: 未读新评论数目
  # * unread_atme_count: 关于我的微博未读数目
  # * unread_messages_count: 未读站内信数目
  # * last_post_id: 最后一次发表的微博
  # * fans_users_count: 粉丝数
  # * follow_users_count: 关注数
  # * user_kids_count: 孩子数
  # * posts_count: 微博数
  # * created_at: 创建时间
  def self.json_attrs
    %w{id email name gender domain score unread_fans_count unread_comments_count unread_atme_count unread_messages_count last_post_id fans_users_count follow_users_count user_kids_count posts_count mms_level created_at}
  end
  
  # ==json_methods 输出方法
  # * description: 个人描述
  # * province_name: 省份
  # * city_name: 城市
  # * logo_url: 默认图片地址450x450
  # * logo_url_thumb140: 140x140 缩略图地址
  # * logo_url_thumb30: 30x30 缩略图地址
  # * logo_url_thumb48: 48x48 缩略图地址
  def self.json_methods
    #%w{province_name city_name logo_url logo_url_thumb140 logo_url_thumb30 logo_url_thumb48 sina_weibo_mms qq_weibo_mms sina_weibo_lama qq_weibo_lama claps}
    %w{province_name city_name logo_url logo_url_thumb140 logo_url_thumb30 logo_url_thumb48}
  end
  
  #喜欢的微博数
  def claps
    Post.find_by_sql("SELECT count(distinct tp_id) as t from claps where user_id = #{self.id} and tp = 'post'")[0]["t"].to_i
  end
  
  # 默认图片地址450x450
  def logo_url
    logo.try(:url)
  end
  
  # 140x140 缩略图地址
  def logo_url_thumb140
    logo.try(:thumb140).try(:url)
  end
  
  # 30x30 缩略图地址
  def logo_url_thumb30
    logo.try(:thumb30).try(:url)
  end
  
  # 48x48 缩略图地址
  def logo_url_thumb48
    logo.try(:thumb48).try(:url)
  end
  
  #个人简介
  def description
    user_profile.try(:content)
  end
  
  def province_name
    #Province.cache_find(self.province_id).try(:name)
    Rails.cache.fetch("province_name_#{self.province_id}"){ self.province.try(:name) }
  end
  
  def city_name
    Rails.cache.fetch("city_name_#{self.city_id}"){ self.city.try(:name) }
  end
  
  alias :status :last_post
  
  def as_json(options = {})
    if options[:stay]
      only = User.attribute_names
      only.delete("logo")
      return super(:only=>only)
    end

    return 'null' if self.blank?
    options[:only] = (options[:only] || []) + User.json_attrs
    options[:methods] = (options[:methods] || []) + User.json_methods
    options[:include] ||= {:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}
    #options[:include] ||= {:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}
    super options
  end

  def as_indexed_json(options={})
    options[:stay] = true;
    as_json(options)
  end
  
  def add_default_logo
    if !self.logo
      if self.gender == 'm'
        file = File.open("public/images/login/logo/#{27 + rand(21)}.jpg", 'rb')
        self.logo = file
      else
        file = File.open("public/images/login/logo/#{1+rand(25)}.jpg", 'rb')
        self.logo = file
      end
      
      self.save(:validate=>false)
      file.close
    end
  end
  
  #添加对妈妈晒的默认关注，关注昨天的宝宝日历达人
  #此功能暂停 2014-04-09 刘明星
  def add_mms_follow
    FollowUser.create(:follow_user_id => 431, :user_id => self.id)
    return;

    for vip in BbrlVip.find(:all)
      next if !vip.user
      if FollowUser.count(:conditions=>"follow_user_id = #{vip.user_id} and user_id= #{self.id}") == 0
        FollowUser.create(:follow_user_id => vip.user_id, :user_id => self.id)
      end
    end
  end
  
  def sina_weibo_mms
    token = Weibotoken.get("sina")
    return false if !token
    return true if UserWeibo.find(:first, :conditions=>"user_id = #{self.id} and tp='#{token.tp}'")
    return false
  end
  
  def sina_weibo_lama
    token = Weibotoken.get("sina", "lama")
    return false if !token
    return true if UserWeibo.find(:first, :conditions=>"user_id = #{self.id} and tp='#{token.tp}'")
    return false
  end
  
  def qq_weibo_mms
    token = Weibotoken.get("qq")
    return false if !token
    return true if UserQq.find(:first, :conditions=>"user_id = #{self.id} and tp='#{token.tp}'")
    return false
  end
  
  def qq_weibo_lama
    token = Weibotoken.get("qq", "lama")
    return false if !token
    return true if UserQq.find(:first, :conditions=>"user_id = #{self.id} and tp='#{token.tp}'")
    return false
  end

  #初始化用户等级积分
  def init_level_score
    score = 0
    score += (Time.new - self.created_at)/1.day
    score += 2*Post.count(:conditions=>"user_id = #{self.id} and logo is not null")
    score += Post.count(:conditions=>"user_id = #{self.id} and logo is null")
    score += PostLogo.count(:conditions=>"user_id = #{self.id}", :group=>"post_id").size
    score += 10*Post.count(:conditions=>"user_id = #{self.id} and post_rates_count > 0")
    score += 10*BbrlStar.count(:conditions=>"user_id = #{self.id}")
    self.level_score = score.to_i
    self.save(:validate=>false)
  end

  #增加用户等级分
  def add_level_score(score, desc)
    old_level = self.mms_level
    new_level = 1
    case self.level_score + score
      when 0..19
        new_level = 1
      when 20..99
        new_level = 2
      when 100..199
        new_level = 3
      when 200..399
        new_level = 4
      when 400..999
        new_level = 5
      when 1000..2000
        new_level = 6
      when 2000..1000000
        new_level = 7
      else
        new_level = 1
    end
    if new_level > old_level
      self.mms_level = new_level
      LevelScoreLog.create(:user_id=>self.id, :score=>0, :total_score=>self.level_score + score, :desc=>"升级了")
      #to do: 发推送
      MamashaiTools::ToolUtil.push_aps(self.id, "您的用户等级从#{old_level}升级到#{new_level}了，我们爱你！")
    end

    self.level_score += score
    self.save(:validate=>false)

    LevelScoreLog.create(:user_id=>self.id, :score=>score, :total_score=>self.level_score + score,  :desc=>desc)
  end
end
