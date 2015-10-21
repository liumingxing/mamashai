class UserScoreStatistic < ActiveRecord::Base
  belongs_to :user_score_statistic_config
  belongs_to :user

  def self.save_user_score(user_id,conf_id,score)
    us=UserScoreStatistic.find :first,:conditions=>["user_id = ? and user_score_statistic_config_id = ?",user_id,conf_id]
    if us
      us.score=score
      us.save
    else
      us=UserScoreStatistic.create :user_id=>user_id,:user_score_statistic_config_id=>conf_id,:score=>score
    end
    return us
  end
end
