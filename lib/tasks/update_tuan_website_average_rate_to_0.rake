# -*- coding: utf-8 -*-
namespace :mamashai do
  desc "update_tuan_website_average_rate_to_0"
  task :update_tuan_website_average_rate_to_0  => [:environment] do
    i = 1
    TuanWebsite.find_each() do |tuan_website|
      ActiveRecord::Base.transaction do
        if tuan_website.update_attribute(:average_rate, 0)
          puts "修改　　#{tuan_website.name}　　average_rate：#{tuan_website.average_rate}　　成功！" if i % 10 == 0
        else
          puts "修改　　#{tuan_website.name}　　average_rate：#{tuan_website.average_rate}　　失败！" if i % 10 == 0
        end
        i += 1
      end
    end
  end
end