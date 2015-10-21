class OrderItem < ActiveRecord::Base
  
  belongs_to :order  
  belongs_to :product
  has_many :virtual_product_logs
  serialize :memo,Hash
  attr_reader :print_requirement
  attr_accessor :total
  
  belongs_to :item, :polymorphic => true
  BACK = -1 #退货
  HAS_SENT = 1 #已发货状态
  
  def print_requirement
    Product.find(self.product_id).desc
  end
  
  def self.generate_from_cart_item(cart_item)
    if cart_item.tp == "tuan"
      tuan = cart_item.tuan
      return unless tuan.remain?
      amount = cart_item.try(:amount)||1
      if tuan.max_amount 
        remain_amount = tuan.max_amount - tuan.person_amount
        amount = [amount,remain_amount].min if remain_amount > 0
      end
      order_item = OrderItem.new(:product_id => tuan.id,
                    :product_name => tuan.content,
                    :price => tuan.origin_price,
                    :discount => tuan.discount,
                    :order_price => tuan.current_price,
                    :amount => amount,
                    :item_id => tuan.id,
                    :item_type => 'Tuan')
      order_item.total = 0              
      order_item.total += amount * tuan.current_price
      tuan.update_attributes(:person_amount=>tuan.person_amount+amount)
    elsif cart_item.tp == "na"
      order_item = OrderItem.new(:product_id => cart_item.obj.id,
                    :product_name => cart_item.obj.name,
                    :price => 0,
                    :discount => 0,
                    :order_price => 0,
                    :amount => amount = cart_item.try(:amount)||1,
                    :item_id => cart_item.obj.id,
                    :item_type => 'Na')
      order_item.total = 0              
      #cart_item.obj.profile.has_sent += 1
      #cart_item.obj.profile.save
    elsif cart_item.tp == "babybook"
      
    end
    order_item
  end
  
  def self.generate_from_tuan(tuan,amount=1)
    OrderItem.new(:product_id => tuan.id,
                  :product_name => tuan.content,
                  :price => tuan.origin_price,
                  :discount => tuan.discount,
                  :order_price => tuan.current_price,
                  :amount => amount,
                  :item_id => tuan.id,
                  :item_type => 'Tuan')
    
  end
  
  def tuan
    Tuan.mms.find(self.item_id)
  end
  
  def na
    Gou.find(self.item_id)
  end
  
  def self.update_state(order)
    order.order_items.select{|item| return if item.item_type != "Tuan"}
    ActiveRecord::Base.transaction do
      order.order_items.select{|item| item.tuan.virtual}.each do |item|
        product = item.tuan.virtual_products.first(:conditions=>["state <> ?",'sold_out'])
        item.amount.times{product.buy(order.user_id,item.id)}
        item.product_state =HAS_SENT 
        item.save
      end
    end
  end
  
  def weight_sum
    if self.item_type == "Tuan"
      return self.tuan.weight*self.amount
    elsif self.item_type == "Na"
      return self.na.profile.weight*self.amount
    else 
      0
    end
  end
  
end
