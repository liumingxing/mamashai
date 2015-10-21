# -*- coding: utf-8 -*-
require "rexml/document"

namespace :mamashai do
  desc "generate user_name by the user_id of table order_logs"
  task :generateuser_name_of_order_log  => [:environment] do
    ActiveRecord::Base.transaction do 
      order_logs = OrderLog.all
      order_logs.each do |log|
        puts log.user_id
        if log.user_id == -888
          log.user_name = "系统"
        else
          log.user_name = User.find(log.user_id).name
        end
        log.save
      end
    end
  end
end