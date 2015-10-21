namespace :mamashai do
  desc "抓取淘宝商城数据"
  task :t  => [:environment] do
    for gou in Gou.find(:all, :conditions=>"site_id = 3")
      if gou.brand.to_s[0] == 194
        gou.brand = gou.brand[2, gou.brand.size-2]
        puts "#{gou.id} #{gou.brand}"
        gou.save
      end
    end
  end
end