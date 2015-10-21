# -*- coding: utf-8 -*-
class BookOrder < Order
  
  @@order_states = {
    :new_order => "等待付款",
    :has_paid => "已付款",
    :has_sent => "已快递",
    :finished => "印厂已确认结算(已完成)",
    :user_canceled => "用户取消订单",
    :sys_canceled => "系统取消订单",
    :ready_for_print => "准备印刷",
    :has_printed => "印刷完成",
    :has_closed => "已同印厂结算",
    #:has_confirmed => "印厂确认结算",
    :has_received => "客户已确认收到商品",
    :has_sign_up => "快递已签收",
    :user_problem => "用户问题",
    :other_problem => "其他问题",
    :has_fixed_user => "用户问题已解决",
    :has_fixed_other => "其他问题已解决"
    }
    
   @@array_order_states = [   
    [:new_order,"等待付款"],
    [:has_paid, "已付款"],  
    [:ready_for_print, "准备印刷"],
    [:has_printed, "印刷完成"],
    [:has_sent, "已配送"],    
    [:has_sign_up, "快递已签收"],
    [:has_received,"客户已确认收到商品"],
    [:has_closed,"已同印厂结算"],
    #[:has_confirmed,"印厂确认结算"],   
    [:finished, "印厂确认结算(已完成)"],
    [:line,"<hr/>"],
    [:user_canceled, "用户取消订单"],
    [:sys_canceled, "系统取消订单"],
    [:user_problem, "用户问题"],
    [:other_problem, "其他问题"],
    [:has_fixed_user, "用户问题已解决"],
    [:has_fixed_other, "其他问题已解决"]
   ]
   
  @@order_events = {
    :new_order => "等待付款",
    :pay_up => "已付款",
    :send_goods => "已发货",
    :print => "印刷完成",
    :ready_print => "准备打印",
    :receive => "用户已收到",
    :sign_up => "快递已签收",
    :user_cancel => "用户取消",
    :sys_cancel => "系统取消",
    :pay_to_print => "同印厂结算",
    :confirmed_print => "印厂确认结算",
    :raise_user_exception => "用户问题",
    :raise_other_exception => "其他问题",
    :fix_user_exception => "用户问题已解决",
    :fix_other_exception => "其他问题已解决"
    }
  
  def self.order_states
    @@order_states
  end
  

  def self.mms_order_states
    @@order_states.except([:print,:send_goods])
  end
  
  def self.get_order_state_name(state)
    @@order_states[state.to_sym]
  end
  
  #获得排序后的order_states
  def self.array_order_states
    @@array_order_states
  end
  
  def self.print_order_states
    states = [[:ready_for_print, "准备印刷"],
              [:has_printed, "印刷完成"],
              [:has_sent, "已配送"],    
              [:has_closed,"已同印厂结算"],
              [:finished,"印厂确认结算"]]
  end
  
  def self.print_order_states_keys
    states = ["ready_for_print","has_printed","has_sent","has_closed","finished"]
  end
  
  def get_order_state
    @@order_states[self.state.intern]
  end
  
  def get_order_events
    events = []
    self.state_events.each do |event|
      events << [@@order_events[event],event]
    end
    events
  end
   #妈妈晒客服可以操作的event数组
  def get_mms_order_events
    events = []
    (self.state_events-[:print,:send_goods]).each do |event|
      events << [@@order_events[event],event]
    end
    events
  end
  
   #印厂可以操作的event数组
  def get_print_order_events
    events = []
    (self.state_events-[:sign_up]).each do |event|
      events << [@@order_events[event],event]
    end
    events
  end

  state_machine :initial => :new_order do
    state :has_paid
    state :has_sent
    state :finished
    state :user_problem
    state :user_canceled
    state :sys_canceled
    state :ready_for_print
    state :has_printed
    state :has_closed
    state :has_confirmed
    state :has_received
    state :has_sign_up
    state :has_fixed_user
    state :has_fixed_other

    after_transition  do |order, transition|
      case transition.to_name.to_sym
      when :new_order
        OrderLog.create :log=>"新建订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_paid
        OrderLog.create :log=>"订单已支付", :user_name=>"系统",:order_id=>order.id, :note=>order.note
      when :user_canceled
        order.coupon.cancel if order.coupon
        OrderLog.create :log=>"用户取消订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :user_problem
        OrderLog.create :log=>"出现用户问题", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :other_problem
        OrderLog.create :log=>"出现其他问题", :user_name=>order.operator,:order_id=>order.id, :tp=>1,:note=>order.note
      when :has_sent
        OrderLog.create :log=>"订单已发货<br />快递公司：#{order.express_company}<br />快递单号：#{order.express_order_id}<br />快递时间#{order.express_at.strftime("%Y-%m-%d %H:%M")}<br />", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :sys_canceled
        order.coupon.cancel if order.coupon
        OrderLog.create :log=>"系统取消订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :ready_for_print
        OrderLog.create :log=>"准备印刷", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_printed
        OrderLog.create :log=>"订单印刷完成", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_sign_up
        OrderLog.create :log=>"订单商品已签收", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_received
        OrderLog.create :log=>"用户确认收到订单商品", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_closed
        OrderLog.create :log=>"已和印厂结算该订单", :user_name=>order.operator,:order_id=>order.id,:tp=>1, :note=>order.note
#      when :has_confirmed
#        OrderLog.create :log=>"印厂确认订单已结算", :user_name=>order.operator,:order_id=>order.id,:tp=>1,:user_name=>User.find(order.user_id,:select=>"name").name
      when :has_fixed_user
        OrderLog.create :log=>"用户问题已解决", :user_name=>order.operator,:order_id=>order.id, :tp=>0,:note=>order.note
      when :has_fixed_other
        OrderLog.create :log=>"其他问题已解决", :user_name=>order.operator,:order_id=>order.id, :tp=>1,:note=>order.note
      when :finished
        OrderLog.create :log=>"印厂确认订单已结算,订单完成", :user_name=>order.operator,:order_id=>order.id,:tp=>1, :note=>order.note
      end
    end

    event :pay_up do
      transition :new_order => :has_paid
      transition :has_fixed_other=> :has_paid
      transition :has_fixed_user=> :has_paid
    end

    event :send_goods do
      transition :has_printed => :has_sent
      transition :has_fixed_other=> :has_sent
      transition :has_fixed_user=> :has_sent
    end

    event :print do
      transition :ready_for_print => :has_printed
      transition :has_fixed_other=> :has_printed
      transition :has_fixed_user=> :has_printed
    end

    event :ready_print do
      transition :has_paid => :ready_for_print
      transition :has_fixed_other=> :ready_for_print
      transition :has_fixed_user=> :ready_for_print
    end

    event :receive do
      transition :has_sign_up => :has_received
      transition :has_fixed_other=> :has_received
      transition :has_fixed_user=> :has_received
    end

    event :sign_up do
      transition :has_sent => :has_sign_up
      transition :has_fixed_other=> :has_sign_up
      transition :has_fixed_user=> :has_sign_up
    end

    event :user_cancel do
      transition :new_order => :user_canceled
      transition :has_fixed_other=> :user_canceled
      transition :has_fixed_user=> :user_canceled
    end

    event :sys_cancel do
      transition :new_order => :sys_canceled
      transition :has_fixed_other=> :sys_canceled
      transition :has_fixed_user=> :sys_canceled
    end

    event :raise_user_exception do
      transition :new_order => :user_problem
      transition :has_paid => :user_problem
      transition :has_sent => :user_problem
      #transition :finished => :user_problem
      transition :has_fixed_other=> :user_problem
      transition :has_fixed_user=> :user_problem
      transition :ready_for_print => :user_problem
      transition :has_closed => :user_problem
      transition :has_received => :user_problem
      transition :has_sign_up => :user_problem
    end
    
    event :raise_other_exception do
      transition :new_order => :other_problem
      transition :has_paid => :other_problem
      transition :has_sent => :other_problem
      transition :user_canceled => :other_problem
      transition :sys_canceled => :other_problem
      transition :has_printed => :other_problem
      transition :ready_for_print => :other_problem
      transition :has_closed => :other_problem
      transition :has_received => :other_problem
      transition :has_sign_up => :other_problem
      transition :has_fixed_other => :other_problem
      transition :has_fixed_user=> :other_problem
    end
    
    event :pay_to_print do
      transition :has_received => :has_closed
      transition :has_fixed_other=> :has_closed
      transition :has_fixed_user=> :has_closed
    end
    
    event :confirmed_print do
      #transition :has_closed => :has_confirmed
      transition :has_closed => :finished
      transition :has_fixed_other=> :finished
      transition :has_fixed_user=> :finished
    end
    
    #----疑问
    event :fix_user_exception do
      transition :user_problem => :has_fixed_user
    end
    
    event :fix_other_exception do
      transition :other_problem => :has_fixed_other
    end
    #解决问题后重新回到原来的state
    event :new_order do
      transition :has_fixed_user=> :new_order
      transition :has_fixed_other=> :new_order
    end
    
  end
  
  def pay_by_coupon(coupon_id,user)
    coupon = Coupon.book.unexpired(Time.now).first(:conditions=>["coupons.id=? and coupons.state=? and coupons.user_id=? and coupon_categories.open=?",coupon_id.to_i,'new_coupon',user.id,true])
    return unless coupon
    self.coupon_id = coupon.id
    self.total_money -= coupon.money
    self.favorable_money||=0
    self.favorable_money += coupon.money
    coupon.use_coupon
  end
  
  
  
end
