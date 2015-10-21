namespace :mamashai do
  desc "update rpush feedback"
  task :update_apn_feedback  => [:environment] do
    #清空热点的缓存
    HotPost.delete_all

    #同步商品
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
        @product.o_price = json2["data"]["itemInfoModel"]["priceUnits"][1]["price"] if json2["data"]["itemInfoModel"]["priceUnits"].size > 1
        @product.save
        p @product.id
      end
    end

    offset = 0;
    feedbacks = RpushFeedback.all(:limit=>1000, :offset=>offset, :order=>"id desc", :group=>"device_token");
    while feedbacks.size > 0
    	for feedback in feedbacks
    		device = ApnDevice.find_by_device_token(feedback.device_token)
    		device.active = 0
    		device.save
    		RpushFeedback.delete_all("device_token='#{feedback.device_token}'")
    	end
    	offset += 1000
    	feedbacks = RpushFeedback.all(:limit=>1000, :offset=>offset, :order=>"id desc", :group=>"device_token");
    end

    notifications = RpushNotification.all(:conditions=>"device_token is null and error_description is not null and alert is null")
    for notification in notifications
        for id in notification.registration_ids
            device = ApnDevice.find_by_device_token(id)
            device.active = 0
            device.save

            notification.alert = 't'
            notification.save
        end

    end
  end
end