namespace :mamashai do
  desc "初始化用户等级."
  task :init_user_level  => [:environment] do
    offset = 0
    users = User.all(:order=>"id", :offset=>offset, :limit=>1000)
    while users.size > 0
      for user in users
        p user.id
        user.init_level_score
      end
      offset += 1000
      users = User.all(:order=>"id", :offset=>offset, :limit=>1000)
    end
  end
end
