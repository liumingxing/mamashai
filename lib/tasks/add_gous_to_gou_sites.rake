namespace :mamashai do
  
  desc "add_gous_to_gou_sites"
  task :add_gous_to_gou_sites => [:environment] do
    gou_site = GouSite.first(:conditions => {:name => '红孩子网上商城'})
    puts "该商品不存在！" and return nil if gou_site.blank?
    Gou.find_in_batches do |gous|
      ActiveRecord::Base.transaction do
        gous.each_with_index do |gou, index|
          if gou[:number].blank?
            number = gou[:link].to_i
            link = "http://www.redbaby.com.cn/Product/ProductInfo_01_#{gou[:link]}.htm"
          else
            number = gou[:number]
            link = "http://www.redbaby.com.cn/Product/ProductInfo_01_#{gou[:number]}.htm"
          end
          gou.update_attributes(:link => link, :number => number)
          gou_gou_site = GouGouSite.find_by_gou_id_and_gou_site_id(gou.id, gou_site.id)
          gou_gou_site.update_attributes(:gou_id => gou.id, :gou_site_id => gou_site.id, :price => gou.price, :url => gou.link) if gou_gou_site.present?
          gou_gou_site = GouGouSite.create(:gou_id => gou.id, :gou_site_id => gou_site.id, :price => gou.price, :url => gou.link) if gou_gou_site.blank?
          puts gou_gou_site.inspect if index % 500 == 0
        end
      end
    end
    puts "更新完成！"
  end
  
end