namespace :mamashai do
  desc "update user score statastic"
  task :update_user_score  => [:environment] do
    UserScoreStatisticConfig.all_actives.each do |conf|
      users=User.all :select=>"id"
      users.each do |user|
        user_score=ScoreEvent.sum('score',:conditions=>["user_id = ? and created_at between ? and ?",user.id,conf.start_date,conf.end_date])
        UserScoreStatistic.save_user_score(user.id,conf.id,user_score) if user_score > 0
      end
    end
  end
  
  desc "update 51_activity_score statastic"
  task :update_51_activity_score  => [:environment] do
    conf = UserScoreStatisticConfig.find(2)
    users=User.all :select=>"id"
    users.each do |user|
      user_score=User.spot_users.count(:all,:conditions=>["invite_user_id = ?",user.id])
      UserScoreStatistic.save_user_score(user.id,conf.id,user_score+1) 
    end
  end
  
  
end
