class UnlimitedVirtualProduct < VirtualProduct
  def type_name
    "不限量"
  end
  
  def buy(user_id,order_item_id)
    return if user_id.blank?
    self.sell
    VirtualProductLog.create(:code=>self.code,:password=>self.password,:user_id=>user_id,:virtual_product_id=>self.id,:order_item_id=>order_item_id,:end_time=>calculate_end_time,:begin_time=>self.begin_time||Time.now)
    return self
  end
  
end