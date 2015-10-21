class InviteCode < ActiveRecord::Base
  
  belongs_to :user, :counter_cache => true
  belongs_to :signuped_user,:class_name=> "User",:foreign_key => "signuped_user_id"
   
  validates_presence_of :email
  validates_uniqueness_of :invite_code
  
  def self.create_invite_code(email,user)
    email = email.downcase.strip
    InviteCode.create(:email=>email,:invite_code=>MamashaiTools::TextUtil.rand_8_str,:user_id=>user.id)
  end
  
  def self.vip_user_today_invites_count(user)
    InviteCode.count(:all,:conditions=>['created_at>? and user_id=?',Date.today,user.id])
  end
  
  
end
