require 'mamashai_tools/taobao_util'
require 'json'
include MamashaiTools

namespace :mamashai do
  desc "获取淘宝商品"
  task :get_taobao_comments  => [:environment] do
    offset = 0
    products = TaobaoProduct.find(:all, :conditions=>"id>61504", :offset=>offset, :limit=>1000, :order=>"id")
    while products.size > 0
      for product in products
        product.get_comments()
        p product.id
        sleep(4)
      end
      
      offset += 1000
      products = TaobaoProduct.find(:all, :conditions=>"id>61504",:offset=>offset, :limit=>1000, :order=>"id")
    end
  end
end