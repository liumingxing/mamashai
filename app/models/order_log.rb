class OrderLog < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :user
  after_create :send_to_supplier
  
  private
  
  def send_to_supplier
    order = self.order
    return unless order.is_a?(TuanOrder)
    
    Mailer.deliver_email(Mailer.send_order_user_payup(order)) if self.log=='订单已支付'
    
    begin
      order.order_items.collect{|item|
        if item.item_type == "Tuan"
          if item.tuan.supplier_code
            Mailer.deliver_email(Mailer.send_order_new(order.id,item.tuan)) if self.log=="新建订单"
            Mailer.deliver_email(Mailer.send_order_payup(order.id,item.tuan)) if self.log=='订单已支付'
          end
        else
          #Mailer.deliver_email(Mailer.create_send_order_new(order.id,item.na)) if self.log=="新建订单"
          #Mailer.deliver_email(Mailer.create_send_order_payup(order.id,item.na)) if self.log=='订单已支付'
        end
      }
    rescue => err
    end
  end
  
end
