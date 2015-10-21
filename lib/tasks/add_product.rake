namespace :mamashai do
  desc "更新贴心购产品"
  task :add_mobile => [:environment] do 
    file = File.open("#{::Rails.root.to_s}/public/bafu/mobile2.csv")

    file.each_line{|line|
      for mobile in  line.split("\r")
        Dda.create(:mobile => mobile)
      end
    }

  end

  task :get_mobile_city =>[:environment] do
    require 'open-uri'

    offset = 0
    ddas = Dda.find(:all, :order=>"id", :offset => offset, :limit=>1000, :conditions=>"id > 718829")
    while ddas.size > 0
      for dda in ddas
        p dda.mobile
        begin
          file = open("http://api.k780.com/?app=phone.get&phone=#{dda.mobile}&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json")
          text = file.read
          file.close
          json = ActiveSupport::JSON.decode(text)
          dda.city = json["result"]["att"]
          dda.network = json["result"]["operators"]
          dda.save
        rescue
        end
      end
      offset += 1000
      ddas = Dda.find(:all, :order=>"id", :offset => offset, :limit=>1000, :conditions=>"id > 718829")
    end
  end

  task :update_product => [:environment] do 
    for num_iid in TaoProduct.all(:conditions=>"from_mamashai=1").collect{|t| t.iid}
      txt = `curl http://hws.m.taobao.com/cache/wdetail/5.0/?id=#{num_iid}&ttid=2013@taobao_h5_1.0.0&exParams={}`
      json = ActiveSupport::JSON.decode(txt)
      if json["ret"][0] == "ERRCODE_QUERY_DETAIL_FAIL::宝贝不存在"
        product = TaoProduct.find_by_iid(num_iid)
        product.destroy

        recommand = TaoRecommand.find_by_tao_product_id(product.id)
        recommand.destroy if recommand
      end

      if json["data"] && json["data"]["apiStack"]
        json2 = ActiveSupport::JSON.decode(json["data"]["apiStack"].first["value"])
        
        @product = TaoProduct.find_by_iid(num_iid)
        if json2["data"]["itemControl"]["unitControl"]["errorMessage"] == "已下架"
          p "delete #{@product.id}"
          @product.destroy
          next
        end
        @product.name = json["data"]["itemInfoModel"]["title"]
        @product.price = json2["data"]["itemInfoModel"]["priceUnits"].first["price"]
        if json2["data"]["itemInfoModel"]["priceUnits"].size > 1
          @product.o_price = json2["data"]["itemInfoModel"]["priceUnits"][1]["price"] 
        else
          @product.o_price = @product.price
        end
        @product.save
        p @product.id
      end
    end
  end

  task :add_product  => [:environment] do
    str = %!40297787415
40297603892
40297267998
40297875469
40346088995
40346104848
40330401819
40346508197
40313858305
40298211391
40346344902
40298431192
40346940458
40314246451
40314126741
40298699384
40347100652
40298995140
40299127119
40331173989
40299299071
40331393867
40314582927
40331449788
40315486107
40315206784
40315378524
!

    @category = TaoCategory.find_by_id(1603)
    for num_iid in str.split("\n")
      txt = `curl http://hws.m.taobao.com/cache/wdetail/5.0/?id=#{num_iid}&ttid=2013@taobao_h5_1.0.0&exParams={}`
      json = ActiveSupport::JSON.decode(txt)
      json2 = ActiveSupport::JSON.decode(json["data"]["apiStack"].first["value"])
      
      @product = TaoProduct.find_by_iid(num_iid)
      @product = TaoProduct.new if !@product
      @product.category_id = 1603 if !@product.category_id
      @product.url = json["data"]["itemInfoModel"]["itemUrl"]
      @product.name = json["data"]["itemInfoModel"]["title"]
      @product.pic_url = json["data"]["itemInfoModel"]["picsPath"][0]
      @product.iid = num_iid
      @product.from_mamashai = true
      @product.price = json2["data"]["itemInfoModel"]["priceUnits"].first["price"]
      @product.o_price = json2["data"]["itemInfoModel"]["priceUnits"][1]["price"] if json2["data"]["itemInfoModel"]["priceUnits"].size > 1
      @product.url_mobile = json["data"]["itemInfoModel"]["itemUrl"]
      begin        
            token = Weibotoken.get('sina', 'babycalendar')
            user_weibo = UserWeibo.find(:first, :order=>"id desc")
            text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(@product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
            res_json = JSON.parse(text)
            if res_json['urls'] && res_json['urls'].size > 0
              @product.short_url = res_json['urls'][0]["url_short"]
            end
      rescue  Exception=>err
            logger.info err
      end

      @product.save

      next

      access_params = {"num_iids"=>num_iid,
        "fields" => "num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume"
      }
      
      res = MamashaiTools.taobao_call("taobao.item.get", {"fields"=>"detail_url,num_iid,title,nick,type,cid,seller_cids,props,input_pids,input_str,desc,pic_url,num,valid_thru,list_time,delist_time,stuff_status,location,price,post_fee,express_fee,ems_fee,has_discount,freight_payer,has_invoice,has_warranty,has_showcase,modified,increment,approve_status,postage_id,product_id,auction_point,property_alias,item_img,prop_img,sku,video,outer_id,is_virtual", "num_iid"=>num_iid})
      #res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,item_url", "num_iids"=>num_iid})
      p res
      if res['tbk_items_detail_get_response'] && res['tbk_items_detail_get_response']['total_results'] > 0
        products_json = res['tbk_items_detail_get_response']['tbk_items']['tbk_item']
        p product_json
        for product_json in products_json
          @product = TaoProduct.new
          @product.category_id = 1603
          @product.category_code = @category.code
          @product.url = product_json["item_url"]
          @product.name = product_json["title"]
          @product.pic_url = product_json["pic_url"]
          @product.iid = product_json["num_iid"]
          @product.price = product_json["price"]
          @product.volumn = product_json["volume"]


          @product.url_mobile = product_json["item_url"]
          #res_json = MamashaiTools.taobao_call("taobao.tbk.mobile.items.convert", {"fields"=>"click_url", "num_iids"=>product_json["num_iid"].to_s})
          #logger.info res_json
          #if res_json["tbk_mobile_items_convert_response"]["total_results"] == 1
          #  @product.url_mobile      = res_json["tbk_mobile_items_convert_response"]["tbk_items"]["tbk_item"][0]["click_url"]
          #end
          
          begin        
            token = Weibotoken.get('sina', 'babycalendar')
            user_weibo = UserWeibo.find(:first, :order=>"id desc")
            text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(@product.url_mobile)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
            res_json = JSON.parse(text)
            logger.info res_json
            if res_json['urls'] && res_json['urls'].size > 0
              @product.short_url = res_json['urls'][0]["url_short"]
            end
          rescue  Exception=>err
            logger.info err
          end
          
          #begin
          #  res = MamashaiTools.taobao_call("taobao.taobaoke.items.detail.get ", {"fields"=>"click_url,shop_click_url", "num_iids"=>params[:num_iid].join(',')})
          #  p res
          #  if res["taobaoke_items_detail_get_response"] && res["taobaoke_items_detail_get_response"]["taobaoke_item_details"]
          #    json = res["taobaoke_items_detail_get_response"]["taobaoke_item_details"]["taobaoke_item_detail"][0]
          #    @product.url = json["click_url"]
          #    @product.shop_url = json["shop_click_url"]
          #  end
          #rescue Exception => err
          #  logger.info err
          #end


          @product.save


        end
      end
    end
  end
end
