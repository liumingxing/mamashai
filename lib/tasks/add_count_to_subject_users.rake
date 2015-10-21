# -*- coding: utf-8 -*-
require "rexml/document"

namespace :mamashai do
  desc "add all and weekly posts count of subject to subject_users"
  task :add_count_to_subject_users  => [:environment] do
    ActiveRecord::Base.transaction do 
      SubjectUser.find(:all).each do |su|
        su.update_attributes(:subject_posts_count=>Post.count(:all, :conditions=>["user_id=? and subject_id = ?",su.user_id,su.subject_id]),
                             :week_subject_posts_count=>Post.count(:all, :conditions=>["user_id=? and subject_id = ? and created_at between ? and ?",su.user_id,su.subject_id,Date.today-6,Date.today+1]))
      end
    end
  end
end
