# -*- coding: utf-8 -*-
namespace :mamashai do
  desc "add test follow users"
  task :add_test_follow_users  => [:environment] do
    users = User.all :conditions=>["follow_users_count < 500"],:include=>:follow_users
    user_number = 0
    for user in users
      follow_user_ids = user.follow_users.map{|t| t.follow_user_id}
      500.times.each do |follow_number|
        follow_user_number = user_number*500+follow_number
        user_number = 0 if follow_user_number == users.length - 1
        next if user.id == users[follow_user_number].id || follow_user_ids.include?(users[follow_user_number].id)
        follow_user = FollowUser.new
        follow_user.follow_user_id = users[follow_user_number].id
        follow_user.user_id = user.id
        follow_user.is_fans = 1
        follow_user.save
      end
      user_number += 1
      puts "user #{user.id} is fine"
    end
  end
end
