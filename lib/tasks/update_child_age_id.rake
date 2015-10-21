# -*- coding: utf-8 -*-
require "rexml/document"

namespace :mamashai do
  desc "update child_id of table users"
  task :update_child_age_id  => [:environment] do
    offset = 0
    users = User.find(:all, :offset=>offset, :limit=>1000, :order=>"id")
    while users.size > 0
      for user in users
        Age.update_user_age_id(user)
        p user.id
      end
      offset += 1000
      users = User.find(:all, :offset=>offset, :limit=>1000, :order=>"id")
    end
    puts '-'*10+"update child_id of table users finished"+'-'*10
  end
end
