# -*- coding: utf-8 -*-
require "rexml/document"

namespace :mamashai do
  desc "generate user_profile by users and user_signup"
  task :create_user_profiles  => [:environment] do
     ids = UserProfile.all(:select => "user_id").collect(&:user_id)
     users = User.find(:all,:select=>"id",:conditions=>["id not in (?)",ids])
     users.each do |user|
       UserProfile.create(:user_id=>user.id)
     end
   p 'user_profile has been created'
  end
end