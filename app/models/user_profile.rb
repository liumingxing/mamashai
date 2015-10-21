class UserProfile < ActiveRecord::Base 
  belongs_to :user
  
  validates_presence_of :user_id
  validates_format_of :bind_mobile,:with => /^(13\d{9})$|^(15\d{9})$/,:allow_blank => true,:message=>APP_CONFIG['error_mobile_wrong']
  
  def is_pub_info(tp)
    self.pub_infos && self.pub_infos.split('|').include?(tp)
  end
  
  def update_score_actions(tp)
    score_actions = []
    score_actions = self.score_actions.split('|') if self.score_actions 
    score_actions << tp
    self.update_attributes(:score_actions=>score_actions.join('|'))
  end
  
  ########################### action methods  ############################
  
  def self.is_finish_profile(user,profile)
   (!user.company.blank? && !user.job_title.blank? && !profile.content.blank? && !profile.school.blank?)
  end
  
  
  def self.update_user_profile(params,user)
    params[:user][:name] = User.gsub_user_name(params[:user][:name].strip)
    user.update_attributes(params[:user])
    user_profile = user.user_profile
    
    user_profile.update_attributes(params[:user_profile])
    
    user.user_profile = user_profile
    return user,user_profile
  end 
   
  def self.update_bind_mobile(params,user)
    user_profile = user.user_profile
    if params[:user_profile][:bind_mobile].blank?
      user_profile.errors.add(:bind_mobile,APP_CONFIG['error_mobile_wrong'])
      return user_profile
    end
    user_profile.rand_code = MamashaiTools::TextUtil.rand_8_num_str
    user_profile.update_attributes(params[:user_profile])
    user_profile
  end
  
  
end
