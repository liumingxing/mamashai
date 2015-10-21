namespace :mamashai do
  desc "自动设置热点话题"
  task :set_hot_topic  => [:environment] do
     if Time.now.yday % 2 == 1        #单数日子，要换话题
        hot = WeekTag.first(:conditions=>"current = 1", :order=>"id desc")
        candidates = WeekTag.all(:conditions=>"id > #{hot.id}", :order=>"id")
        candidates.first.current = true
        candidates.first.hide = false
        candidates.first.save
        hot.current = false
        hot.save

        Rails.cache.delete("half_screen_advs_android")
        Rails.cache.delete("half_screen_advs_ios")
     end 
  end
end
