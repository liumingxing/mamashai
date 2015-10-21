class OrgProfile < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id
  
  
  def self.create_user_org_profile(user_signup,user,user_profile)
    ActiveRecord::Base.transaction do
      org_profile = OrgProfile.create(:tps=>user_signup.org_tps,:user_id=>user.id) 
      user.name = user_signup.org_name
      user.mobile = user_signup.mobile
      user.age_ids = user_signup.age_ids
      user.org_profile_id = org_profile.id
      user.save_without_validation
      user_profile.update_attributes(:idcard=>user_signup.idcard,:real_name=>user_signup.name)
    end 
  end
  
end
