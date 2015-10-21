namespace :mamashai do
  desc "catch gous"
  task :catch_gous  => [:environment] do
    puts "开始抓取商品……"
    GouSite.catch_gous('http://localhost:3001/sites/products_xml.xml?id=1')
    puts "抓取商品完成！"
  end
end