class UserSignup < ActiveRecord::Base 
  belongs_to :province
  belongs_to :city
  belongs_to :age
  belongs_to :user
  belongs_to :invite_user,:class_name=> "User",:foreign_key => "invite_user_id"
  
  attr_accessor :password_confirmation, :tp
  
  validates_presence_of :email,:message=>APP_CONFIG['error_signup_email']
  validates_uniqueness_of :email,:message=>APP_CONFIG['error_signup_email_exist']
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message=>APP_CONFIG['error_signup_email_wrong']
  validates_presence_of :password,:message=>APP_CONFIG['error_signup_password'] 
  validates_confirmation_of :password,:on=>:create,:message=>APP_CONFIG['error_signup_password_wrong']
  validates_length_of :password,:within => 6..20,:on=>:create,:too_long=>APP_CONFIG['error_signup_password_length'],:too_short=>APP_CONFIG['error_signup_password_length']
  validates_format_of :password,:with=>/^[a-zA-Z0-9]{6,20}$/,:on=>:create,:message=>APP_CONFIG['error_signup_password_format'] 
  validates_length_of :org_name,:within => 1..20,:too_long=>APP_CONFIG['error_user_name_length'],:too_short=>APP_CONFIG['error_user_name_length'],:allow_blank => true 
  # validates_presence_of :kids_count,:message=>APP_CONFIG['error_signup_kids_count'] 
  
  
  def email_name
    self.email.split('@')[0]
  end
  
  def email_site
    MamashaiTools::TextUtil.email_site(self.email)
  end
  
  def self.create_user_signup(params) 
    begin
      user_signup = UserSignup.new(params[:user_signup])
    rescue
      user_signup = UserSignup.new
      user_signup.errors.add(:tp,APP_CONFIG['error_time_format']) 
      return user_signup
    end
    user_signup.email = user_signup.email.downcase.strip 
    return user_signup unless user_signup.save
    user_signup.update_attributes(:password=>MamashaiTools::TextUtil.md5(user_signup.password),:uuid=>MamashaiTools::TextUtil.uuid)
    user_signup
  end
  
  ######################  init user ########################
  
  def self.create_user_by_uuid(uuid)
    user_signup = UserSignup.find_by_uuid(uuid)
    if user_signup
      return if User.find_by_email(user_signup.email)
      user = User.new(:email=>user_signup.email,:password=>user_signup.password,:invite_user_id=>user_signup.invite_user_id,:is_hide_age=>user_signup.is_hide_age)
      user.save_without_validation
      user_profile = UserProfile.create(:user_id=>user.id)
      if user_signup.org_name.present?
        OrgProfile.create_user_org_profile(user_signup,user,user_profile)
      else
        UserKid.create_user_kids_from_signup(user_signup,user)
      end
      UserSignup.update_invite_code_user_id(user,user_signup) if user_signup.invite_user_id 
      user_signup.destroy
      ######## vip users auto add follows ###############
     # User.auto_follow_vip_and_mms_users(user)
    end
    user
  end
  
  def self.update_invite_code_user_id(user,user_signup)
    invite_user = user_signup.invite_user
    if invite_user 
      invite_code = InviteCode.find(:first,:conditions=>['user_id=? and email=?',invite_user.id,user.email])
      invite_code.update_attributes(:signuped_user_id=>user.id) if invite_code
    end
  end
  
  ###################### password ########################3#
  
  def self.reset_password(params)
    user_signup = UserSignup.new(params[:user_signup])
    if user_signup.email.blank?
      user_signup.errors.add(:email,APP_CONFIG['error_signup_email']) 
      return user_signup
    end
    user = User.find_by_email(user_signup.email)
    unless user 
      user_signup.errors.add(:email,APP_CONFIG['error_find_password_email'])
      return user_signup
    end
    old_user_signup = UserSignup.find_by_email(user_signup.email)
    old_user_signup.destroy if old_user_signup
    user_signup = UserSignup.new(:email=>user.email,:password=>user.password,:password_reset=>MamashaiTools::TextUtil.rand_8_str,:uuid=>MamashaiTools::TextUtil.uuid,:user_id=>user.id)
    user_signup.save_without_validation
    return user_signup
  end
  
  def self.confirm_reset_password_by_uuid(uuid)
    user_signup = UserSignup.find_by_uuid(uuid)
    if user_signup
      user = user_signup.user
      user.update_attributes(:password=>MamashaiTools::TextUtil.md5(user_signup.password_reset))
      user_signup.destroy
    end
    user
  end
  
  ################## validate #################
  
  def validate
    if User.find_by_email(self.email)
      self.errors.add(:email,APP_CONFIG['error_signup_email_exist']) 
    end
    if self.org_name && User.find_by_name(self.org_name)
      self.errors.add(:org_name,APP_CONFIG['error_org_name_exist']) 
    end
    if self.kids_count && self.kids_count>=1 && (self.kid_gender1.blank? or self.kid_birthday1.blank?)
      self.errors.add(:tp,APP_CONFIG['error_signup_kids']) 
    end
    if self.kids_count && self.kids_count>=2 && (self.kid_gender2.blank? or self.kid_birthday2.blank?)
      self.errors.add(:tp,APP_CONFIG['error_signup_kids']) 
    end
    if self.kids_count && self.kids_count>=3 && (self.kid_gender3.blank? or self.kid_birthday3.blank?)
      self.errors.add(:tp,APP_CONFIG['error_signup_kids']) 
    end
    if self.kids_count && self.kids_count==0 && self.kid_birthday4.blank?
      self.errors.add(:tp,APP_CONFIG['error_signup_kids']) 
    end
    if self.kids_count && self.kids_count==0 && !self.kid_birthday4.blank?
      days = self.kid_birthday4.to_date - Date.today
      if days<=0 or days>=280
        self.errors.add(:tp,APP_CONFIG['error_signup_have_baby_time']) 
      end
    end
  end
  
  
  
end
