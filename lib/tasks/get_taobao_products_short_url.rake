require 'mamashai_tools/taobao_util'
require 'json'
require 'uri'
include MamashaiTools

namespace :mamashai do
  desc "获取淘宝商品短域名"
  task :get_taobao_products_short_url => [:environment] do
    token = Weibotoken.get('sina', 'babycalendar')
    user_weibo = UserWeibo.find(:first, :order=>"id desc")

    offset = 0;
    products = TaoProduct.find(:all, :conditions=>"short_url is null", :offset=>offset, :limit=>8)
    while products.size > 0
      url = products.map{|product| 'url_long=' + URI.encode(product.url_mobile)}.join('&')
      text = `curl 'https://api.weibo.com/2/short_url/shorten.json?#{url}&access_token=2.00LJm1PB_EQU4D0686d9995d3LWIRD&source=#{token.token}&access_token=#{user_weibo.access_token}'`
      json = JSON.parse(text)
      if json['error']
        p text
      end
      json['urls'].each_with_index{|short, i|
        next if !short['result']
        p short['url_long']
        products[i].short_url = short['url_short']
        products[i].save
        p products[i].id
      }
      offset += 8
      products = TaoProduct.find(:all, :conditions=>"short_url is null", :offset=>offset, :limit=>8)
    end
  end
end