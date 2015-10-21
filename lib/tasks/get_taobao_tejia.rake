require 'nokogiri'
require 'uri'
require 'open-uri'

require 'mamashai_tools/taobao_util'
include MamashaiTools

namespace :mamashai do
  desc "获取淘宝天天特价"
  task :get_taobao_tejia  => [:environment] do
    p Time.new
    TaoYouhuiProduct.delete_all
    for category in TaoYouhuiCategory.all
      p category.code
      all = Nokogiri::HTML(open("http://tejia.taobao.com/tejia_list.htm?pid=9&cid=#{category.code}"))
      all.css('div.filter-list-detail ul.clrfix li.par-item dl').each do |dl|
      	a = dl.css('dd.title a')[0]
      	
      	price = dl.css('dd strong').text
      	
      	name = a.text
      	a['href'].scan(/id=(\d+)&/)
      	iid = $1

      	p name
      	p iid
      	p price

      	#res = MamashaiTools.taobao_call("taobao.taobaoke.items.convert", {"fields"=>"num_iid,cid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,promotion_price", "num_iids"=>iid,  'is_mobile'=>"true"})
      	#res = MamashaiTools.taobao_call("taobao.taobaoke.items.detail.get", {"fields"=>"num_iid,cid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,promotion_price", "num_iids"=>iid,  'is_mobile'=>"true"})
      	
  	    res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,cid,title,nick,pic_url,price,item_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,promotion_price", "num_iids"=>iid.to_s})
  	    p res
        if res['tbk_items_detail_get_response'] && res['tbk_items_detail_get_response']['total_results'] > 0
          product_json = res['tbk_items_detail_get_response']['tbk_items']['tbk_item'][0]
          product = TaoYouhuiProduct.new
          product.youhui_code = category.code
          product.name = name
          product.pic_url = product_json["pic_url"]
          product.iid = iid
          product.o_price = product_json["price"]
          product.price = price.to_f
          product.url = product_json['item_url'] + "&ali_trackid=2:mm_26156568_0_0:1389886756_6k2_1847772503"

          product.save
        end
      end
    end

    p Time.new
  end
end