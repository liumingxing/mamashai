class BestFollowUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :follow_user, :class_name=> "User",:foreign_key => "follow_user_id"
  
  validates_presence_of :user_id
  validates_presence_of :follow_user_id
  
  #################### create ####################
  
  def self.create_best_follow_user(params,user)
    best_follow_ids = user.best_follows.collect{|follow| follow.id}
    ActiveRecord::Base.transaction do
      params[:follow_ids].each do |follow_id|
        follow_user_id = follow_id[0].to_i
        if follow_id[1]=='1'
          if user.id != follow_user_id && !best_follow_ids.include?(follow_user_id)
            BestFollowUser.create(:user_id=>user.id,:follow_user_id=>follow_user_id)
          end
        else
          if best_follow_ids.include?(follow_user_id)
            BestFollowUser.find_by_user_id_and_follow_user_id(user.id,follow_user_id).destroy
          end
        end
      end
    end
  end
  
end
