


module MamashaiTools
  class RewardUtil
    def initialize
    end
    
    def self.build_book_100126_rewards
      User.find(:all,:conditions=>['score > 260 and id > 115'],:order=>'score desc').each do |user|
        UserReward.create(:reward=>'book_100126',:get_reward_at=>'2010-01-26',:user_id=>user.id)
      end
    end
    
    def self.find_book_100126_reward_users
      User.find(:all,:conditions=>['user_rewards.reward = ? ','book_100126'],:include=>[:user_rewards],:order=>'user_rewards.id asc')
    end
    
    def self.find_rand_book_100126_reward_users
      User.find(:all,:limit=>5,:conditions=>['user_rewards.reward = ? ','book_100126'],:include=>[:user_rewards],:order=>'rand()')
    end
    
    ################# 100301  ###################
    
    def self.find_book_100401_reward_users
      User.find(:all,:conditions=>['user_rewards.reward = ? ','book_100401'],:include=>[:user_rewards],:order=>'user_rewards.id asc')
    end
    
    def self.find_book_100301_reward_users
      User.find(:all,:conditions=>['user_rewards.reward = ? ','book_100301'],:include=>[:user_rewards],:order=>'user_rewards.id asc')
    end
    
     def self.find_rand_book_100301_reward_users
      User.find(:all,:limit=>5,:conditions=>['user_rewards.reward = ? ','book_100301'],:include=>[:user_rewards],:order=>'rand()')
    end
    
  end
end
