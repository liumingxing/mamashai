namespace :mamashai do
  desc "update gous link"
  task :update_gous_link  => [:environment] do
    puts "开始更新……"
    Gou.find_in_batches do |gous|
      ActiveRecord::Base.transaction do
        gous.each do |gou|
          gou.update_attribute(:link, gou[:link].try(:split, 'http://www.redbaby.com.cn/Product/ProductInfo_01_').try(:last).try(:split, '.').try(:first))
        end
      end
    end
    puts "更新完成！"
  end
end