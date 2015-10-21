class UserReward < ActiveRecord::Base 
  belongs_to :user
  
  validates_presence_of :user_id
  
  
  def self.create_user_rewards
    ActiveRecord::Base.transaction do
      users = User.find(:all,:conditions=>['score>=660 and id > 112 and tp>=1  and tp < 10'])
      ScoreEvent.find(:all,:conditions=>['score=-660']).each do |score_event|
        users << score_event.user
      end
      users.each do |user|
        unless UserReward.find(:first,:conditions=>['(reward=? or reward=?) and user_id=?','book_100126','book_100301',user.id])
          UserReward.create(:reward=>'book_100301',:user_id=>user.id,:get_reward_at=>Date.today)
        end
      end
    end
  end
  
end
