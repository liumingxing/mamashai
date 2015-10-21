class SingleVirtualProduct < VirtualProduct
  belongs_to :tuan, :counter_cache => :max_amount
  after_save :change_max_amount,:unless=>Proc.new{|product| product.tp == 0}
  
  def type_name
    "单用户"
  end
  
  def buy(user_id,order_item_id)
    return if user_id.blank?
    if self.tp==0
      self.sell_out
      VirtualProductLog.create(:user_id=>user_id,:virtual_product_id=>self.id,:order_item_id=>order_item_id,:end_time=>calculate_end_time,:begin_time=>self.begin_time||Time.now,:code=>self.code,:password=>self.password)
    else
      self.sell
      VirtualProductLog.create(:user_id=>user_id,:virtual_product_id=>self.id,:order_item_id=>order_item_id,:code=>generate_random_code(order_item_id),:password=>generate_random_password(user_id,order_item_id),:end_time=>calculate_end_time,:begin_time=>self.begin_time||Time.now)
    end
    return self
  end
  
  def change_max_amount
    Tuan.update_all("max_amount=NULL",["id=?",self.tuan_id])
  end
  
end