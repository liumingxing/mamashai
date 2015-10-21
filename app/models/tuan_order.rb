# -*- coding: utf-8 -*-
class TuanOrder < Order
  attr_reader :free_fright
  after_create :new_order_log
  after_save :change_balance
  named_scope :good, :conditions=>["total_item_money >=?",5]
  named_scope :supplier, lambda { |code|{ :conditions => ["tuans.supplier_code = ?",code],:joins=>"inner join order_items on order_items.order_id = orders.id inner join tuans on order_items.product_id = tuans.id" }}
  
  def sent_address
    [receiver_name, receiver_mobile, info[:phone], full_address, info[:receiver_post_code]].select{|a|a.present?}.join('，')
  end
  
  def full_address
    city = City.find(info[:city_id]) unless info[:city_id].blank?
    city_name = city.try(:name)
    province = Province.find(info[:receiver_province_id]) unless info[:receiver_province_id].blank?
    province_name = province.try(:name)
    [province_name, city_name, receiver_address].compact.join('－')
  end
  
  #从order_address中读取地址信息，并计算邮费
  def copy_address(order_address,tuan=nil)
    city = order_address.city
    self.user_id = order_address.user_id
    self.receiver_name = order_address.name
    self.receiver_address = order_address.address
    self.receiver_mobile = order_address.mobile
    self.info = {}
    self.info[:receiver_province_id]=order_address.province_id
    self.info[:city_id]=order_address.city_id
    self.info[:memo]=order_address.memo
    self.info[:receiver_post_code] = order_address.post_code
    self.info[:email] = order_address.email
    self.info[:phone] = order_address.phone
    self.info[:product_id] = tuan.id if tuan
  end
  
  def record_order_item(tuan,amount,city)
    tuan_order_item = OrderItem.generate_from_tuan(tuan,amount)
    self.order_items << tuan_order_item
    self.record_price_tuan(tuan,tuan_order_item.amount,city)
  end
  
  ####邮费改动
  def record_price_tuan(tuan,amount,city)
    city_fright_money= city.fright_fee + (self.over_weight)*city.add_on_fright_fee
    self.fright_money = 0 if tuan.fright_money == 0
    #favorable_money保存减免的邮费，以后还会加优惠券
    self.favorable_money = city_fright_money - self.fright_money
    self.total_item_money = tuan.current_price * amount
    self.total_money = total_item_money+self.fright_money
  end
  
  #从购物车中读取订单项  
  def record_order_item_by_cart(cart,city)
    #不需要付邮费
    @free_fright = true
    cart.items.each do |cart_item|
      order_item = OrderItem.generate_from_cart_item(cart_item)
      if cart_item.tp == "tuan"
        tuan = order_item.tuan
        @free_fright = false if self.order_items << order_item and tuan.need_fright? and order_item.amount < (tuan.free_fright_amount||0)
      elsif cart_item.tp == "na"
        self.order_items << order_item
        @free_fright = false
      end
    end
    self.record_price(city)
  end
  
  #计算价格
  def record_price(city)
    self.fright_money = 0 
    city_fright_money = 0
    city_fright_money = city.fright_fee+(self.over_weight)*city.add_on_fright_fee if items_weight > 0
    self.fright_money = city_fright_money unless @free_fright
    self.favorable_money = city_fright_money - self.fright_money
    self.total_item_money = self.order_items.inject(0){|total,item| total+= item.total}
    self.total_money = total_item_money+self.fright_money
  end
  
  @@order_states = {
     :new_order => "未付款",
     :has_paid => "已付款",
     :has_sent => "已发货",
     :user_canceled => "订单已取消",
     :sys_canceled => "订单已取消",
     :user_problem => "用户问题",
     :sys_problem => "系统问题",
     :fixed_user_problem => "用户问题已解决",
     :fixed_sys_problem => "系统问题已解决",
     :has_sign_up => "快递已签收",
     :has_received => "已收到商品",
     :has_closed => "订单已过期",
     :finished => "供应商已结算"
  }
  
  @@order_events = {
    :new_order => "未付款",
    :pay_up => "已付款",
    :send_goods => "已发货",
    :sign_up => "快递已签收",
    :receive => "已收到商品",
    :user_cancel => "用户已取消",
    :sys_cancel => "系统已取消",
    :raise_user_exception => "用户问题",
    :raise_other_exception => "其他问题",
    :fix_user_exception => "用户问题已解决",
    :fix_other_exception => "其他问题已解决",
    :expired => "过期",
    :finish => "完成"
  }
  
  def get_order_state
    @@order_states[self.state.intern]
  end
  
  def self.tuan_partners_order_states
    states = [[:has_paid, "已付款"]]
  end
  
  def self.tuan_partners_order_states_keys
    states = ["has_paid","has_sent","has_closed","finished"]
  end
  
  def self.get_order_states
    states = []
    TuanOrder.state_machine.states.each do |state|
      states << [@@order_states[state.name], state.value]
    end
    return states
  end
  
  def get_order_events
    events = []
    self.state_events.each do |event|
      events << [@@order_events[event],event]
    end
    events
  end
  
  def pay_by_balance(balance,user_balance)
    self.using_balance = [user_balance,balance,self.total_money].min
    self.total_money -= self.using_balance
    sql = ActiveRecord::Base.connection()
    sql.update("update users set users.balance = ROUND(users.balance-#{self.using_balance},2) where users.id=#{self.user_id}")
    BalanceLog.create(:user_id=>self.user_id,:operator_id=>-888,:log=>"消费",:payment=>"支出",:cash=>self.using_balance)
  end
  
  def pay_by_coupon(coupon_id,user)
    coupon = Coupon.tuan.unexpired(Time.now).first(:conditions=>["coupons.id=? and coupons.state=? and coupons.user_id=? and coupon_categories.open=?",coupon_id.to_i,'new_coupon',user.id,true])
    return unless coupon
    self.coupon_id = coupon.id
    self.total_money -= coupon.money
    self.favorable_money += coupon.money
    coupon.use_coupon
  end
  
  def return_money
    if self.using_balance > 0
      sql = ActiveRecord::Base.connection()
      sql.update("update users set users.balance = users.balance+#{self.using_balance} where users.id=#{self.user_id}")
      BalanceLog.create(:user_id=>self.user_id,:operator_id=>-888,:log=>"退回款项 - 订单号 #{self.order_sn}",:payment=>"收入",:cash=>self.using_balance)
    end
  end
  
  def change_balance
    user = self.user
#    Mms::Score.trigger_event(:create_order, "购买商品", 1, 10, {:cond => :by_first_order_id, :user => user, :order => self, :total => (self.fright_money + self.total_item_money)}) if self.state == "has_paid" and self.total_item_money > 0
    if self.state=="has_paid" and self.coupon_id.blank? and !user.has_grant and self.total_item_money >= 5
      invite_user = user.invite_tuan_user
      begin
        back_money = self.order_items.map{|item| item.tuan.back_money}.max
      rescue
        back_money = 0.0
      end
      if invite_user and back_money 
        ActiveRecord::Base.transaction do 
          User.update_all("users.balance = users.balance+#{back_money}",["users.id = ?",invite_user.id])
          user.update_attribute(:has_grant,true)
          BalanceLog.create(:user_id=>invite_user.id,:operator_id=>self.user_id,:log=>"邀请好友奖励",:payment=>"收入",:cash=>back_money)          
        end
      end
    end
  end
  
  def award_money
    ActiveRecord::Base.transaction do 
      User.update_all("users.balance = users.balance+1",["users.id = ?",self.user_id])
      BalanceLog.create(:user_id=>self.user_id,:operator_id=>-888,:log=>"返利",:payment=>"收入",:cash=>1)
    end
  end
  
  def cancel
    self.order_items.each do |item|
      tuan = item.tuan
      tuan.update_attributes(:person_amount => (tuan.person_amount-item.amount.to_i))
    end
    coupon.cancel if self.coupon
  end
  
  #判断本订单是否参与邀请好友奖励
  def get_back_money
    self.order_items.max{|item| item.tuan.back_money}
  end
  
  #订单总重
  def items_weight
    return self.order_items.inject(0){|sum,item| item.weight_sum}
  end
  
  #超重
  def over_weight
    total_weight = items_weight.to_i
    return total_weight == items_weight ? total_weight-1 : total_weight
  end
  
  state_machine :initial => :new_order do
    state :new_order
    state :has_paid #已付款
    state :has_sent #已配送
    state :user_canceled #用户取消
    state :sys_canceled #系统取消
    state :user_problem #用户问题
    state :sys_problem  #系统问题
    state :fixed_user_problem 
    state :fixed_sys_problem
    state :has_sign_up
    state :has_received
    state :has_closed #已过期
    state :finished
    
    after_transition  do |order, transition|
      case transition.to_name.to_sym
      when :new_order
        OrderLog.create :log=>"新建订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :has_paid
        OrderItem.update_state(order)
        OrderLog.create :log=>"订单已支付", :user_name=>"系统",:order_id=>order.id, :note=>order.note
      when :has_sent
        OrderLog.create :log=>"订单已发货<br />快递公司：#{order.express_company}<br />快递单号：#{order.express_order_id}<br />快递时间：#{order.express_at.strftime("%Y-%m-%d %H:%M") unless order.express_at.blank?}<br />", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :user_canceled
        order.cancel
        OrderLog.create :log=>"用户取消订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :sys_canceled
        order.cancel
        OrderLog.create :log=>"系统取消订单", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :user_problem
        OrderLog.create :log=>"用户出现问题", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :sys_problem
        OrderLog.create :log=>"系统出现问题", :user_name=>order.operator,:order_id=>order.id, :note=>order.note
      when :fixed_user_problem
        OrderLog.create :log=>"用户问题已解决", :user_name=>order.operator,:order_id=>order.id, :tp=>0,:note=>order.note
      when :fixed_sys_problem
        OrderLog.create :log=>"系统问题已解决", :user_name=>order.operator,:order_id=>order.id, :tp=>0,:note=>order.note
      when :has_sign_up
        OrderLog.create :log=>"订单商品已签收", :user_name=>order.operator,:order_id=>order.id, :tp=>0,:note=>order.note
      when :has_received
        OrderLog.create :log=>"用户确认收到订单商品", :user_name=>order.operator,:order_id=>order.id, :tp=>0,:note=>order.note
      when :has_closed
        OrderLog.create :log=>"订单已过期", :user_name=>order.operator,:order_id=>order.id,:tp=>1, :note=>order.note
      when :finished
        OrderLog.create :log=>"供应商确认订单已结算,订单完成", :user_name=>order.operator,:order_id=>order.id,:tp=>1, :note=>order.note
      end
    end
    
    event :pay_up do
      transition :new_order => :has_paid
      transition :fixed_user_problem=> :has_paid
      transition :fixed_sys_problem=> :has_paid
    end

    event :send_goods do
      transition :has_paid => :has_sent
      transition :fixed_user_problem => :has_sent
      transition :fixed_sys_problem => :has_sent
    end

    event :receive do
      transition :has_sign_up => :has_received
      transition :fixed_user_problem => :has_received
      transition :fixed_sys_problem => :has_received
    end

    event :sign_up do
      transition :has_sent => :has_sign_up
      transition :fixed_user_problem => :has_sign_up
      transition :fixed_sys_problem => :has_sign_up
    end

    event :user_cancel do
      transition :new_order => :user_canceled
      transition :fixed_user_problem=> :user_canceled
      transition :fixed_sys_problem=> :user_canceled
    end

    event :sys_cancel do
      transition :new_order => :sys_canceled
      transition :fixed_user_problem=> :sys_canceled
      transition :fixed_sys_problem=> :sys_canceled
    end

    event :raise_user_exception do
      transition :new_order => :user_problem
      transition :has_paid => :user_problem
      transition :has_sent => :user_problem
      transition :fixed_user_problem=> :user_problem
      transition :fixed_sys_problem=> :user_problem
      transition :has_closed => :user_problem
      transition :has_received => :user_problem
      transition :has_sign_up => :user_problem
    end
    
    event :raise_other_exception do
      transition :new_order => :sys_problem
      transition :has_paid => :sys_problem
      transition :has_sent => :sys_problem
      transition :user_canceled => :sys_problem
      transition :sys_canceled => :sys_problem
      transition :has_closed => :sys_problem
      transition :has_received => :sys_problem
      transition :has_sign_up => :sys_problem
      transition :fixed_user_problem => :sys_problem
      transition :fixed_sys_problem=> :sys_problem
    end
    
    event :expired do
      transition :new_order => :has_closed
      transition :has_paid => :has_closed
      transition :has_sent => :has_closed
      transition :user_canceled => :has_closed
      transition :sys_canceled => :has_closed
      transition :has_received => :has_closed
      transition :has_sign_up => :has_closed
      transition :fixed_user_problem => :has_closed
      transition :fixed_sys_problem=> :has_closed
    end
    
    #----疑问
    event :fix_user_exception do
      transition :user_problem => :fixed_sys_problem
    end
    
    event :fix_other_exception do
      transition :sys_problem => :fixed_user_problem
    end
    
    #解决问题后重新回到原来的state
    event :new_order do
      transition :fixed_sys_problem=> :new_order
      transition :fixed_user_problem=> :new_order
    end
    
    event :finish do
      transition :has_closed => :finished
    end
    
  end
  
  
  private 
  
  def new_order_log
    OrderLog.create :log=>"新建订单", :user_name=>self.operator,:order_id=>self.id, :note=>self.note
  end
  
end
