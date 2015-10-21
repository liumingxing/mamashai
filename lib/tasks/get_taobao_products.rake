require 'mamashai_tools/taobao_util'
require 'mamashai_tools/taobao_util'
include MamashaiTools

namespace :mamashai do
  desc "获取淘宝商品"
  task :get_taobao_products  => [:environment] do
    position = Time.new.to_i
    for category in TaoCategory.find(:all)
      next if category.is_parent
      p "---------------------#{category.code}-------------------"
      
      page_no = 1
      json = MamashaiTools.taobao_call("taobao.taobaoke.items.get", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume", 'cid'=>category.code, 'is_mobile'=>"true", 'start_credit'=>'1diamond', 'start_totalnum'=>"1000", 'page_size'=>"40", 'page_no'=>page_no.to_s, 'outer_code'=>'babycalendar', 'sort'=>"commissionNum_desc"})
      p category.name
      if !json['taobaoke_items_get_response']
        p json
        next 
      end
      p json['taobaoke_items_get_response']['total_results']
      while json['taobaoke_items_get_response']['total_results'] > 0
        if !json['taobaoke_items_get_response']['taobaoke_items'] || !json['taobaoke_items_get_response']['taobaoke_items']['taobaoke_item']
          p 'fuck'
          break;
        end
        for product in json['taobaoke_items_get_response']['taobaoke_items']['taobaoke_item']
          t = TaoProduct.new(:category_id=>category.id, :category_code=>category.code)
          t.name = product['title']
          t.iid = product['num_iid']
          t.price = product['price']
          t.url_mobile = product["click_url"]
          t.shop_url = product["shop_click_url"]
          t.pic_url = product["pic_url"]
          t.location = product["item_location"]
          t.volumn = product["volume"]
          t.commission = product["commission"]
          t.commission_num = product["commission_num"]
          t.commission_rate = product["commission_rate"]
          t.position =position
          begin
            t.save
          rescue Exception=>err
            p err
          end
          p t.name
        end
        page_no += 1
        break if page_no > 50

        json = MamashaiTools.taobao_call("taobao.taobaoke.items.get", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume", 'cid'=>category.code, 'is_mobile'=>"true", 'start_credit'=>'1diamond', 'start_totalnum'=>"1000", 'page_size'=>"40", 'page_no'=>page_no.to_s, 'sort'=>"commissionNum_desc"})
        if !json['taobaoke_items_get_response']
          p json
          break;
        end
      end
    end
  end
end