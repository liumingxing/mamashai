class Cart  
  attr_accessor :using_balance, :coupon
  def initialize(data=nil, coupon_id=nil)
    @items=[]
    @using_balance ||= 0
    parse_data(data) if data
    @coupon = Coupon.find(coupon_id) if coupon_id && coupon_id != 0
  end
  
  def items
    return @items
  end
  
  def use_coupon(coupon)
    @coupon = coupon  
  end
  
  def can_use_coupon?
    for item in @items
      return true if item.tp == "tuan" && item.tuan.current_price>0 || item.tp == "tuan" && item.tuan.need_fright?
    end
    false
  end
  
  #总数量
  def items_amount
    amount = items.inject(0){|amount,it| amount+=it.amount}
    return amount
  end
  
  #总重量
  def items_weight
    return @items.sum{|item| item.weight_sum}
  end
  #超重
  def over_weight
    total_weight = items_weight.to_i
    return total_weight>=1 ? total_weight-1 : total_weight
  end
  
  def update_amount(p_id,amount)
    item=@items.select{|item| item.product_id == p_id.to_i}.first
    item.amount = amount  if item
    return self
  end
  
  def add_product(p_id,amount=1)
    item=@items.select{|item| item.product_id == p_id.to_i}.first
    if item
      item.amount += amount.to_i
    else
      begin 
        item = ShoppingCartItem.new(p_id,amount) 
        @items << item
      rescue
      end
    end
    return self
  end
  
  def remove_product(p_id)
    @items.delete_if do |item|
      item.product_id == p_id.to_i
    end
    return self
  end
  
  ###########免费拿操作开始############
  def add_na(na, amount=1)
    raise "已经被拿光了" if na.profile.has_sent >= na.profile.total_count
    begin
      item = Item.new(na.id, amount, "na")
      @items << item
    rescue => e
      puts "向购物车中添加产品发生错误："+e.inspect.to_s
    end
    self
  end
  
  ############团购操作开始#############
  def add_tuan(tuan,amount=1)
    raise "团购已卖光" unless tuan.remain?
    tuan_id = tuan.id
    item=@items.select{|item| item.tuan_id == tuan_id}.first
    if item
      item.amount += amount.to_i if tuan.tp==1
      item.amount = [item.amount,tuan.remain_amount].min
    else
      begin 
        item = Item.new(tuan_id,amount)
        @items << item
      rescue => e
        puts "向购物车中添加产品发生错误："+e.inspect.to_s
      end
    end
    self
  end
  
  def remove_tuan(t_id)
    @items.delete_if{|item| item.obj.id == t_id.to_i}
    self
  end
  
  def update_tuan(t_id,amount)
    item=@items.select{|item| item.tuan_id == t_id.to_i}.first
    tuan = item.tuan
    item.amount = [amount.to_i,tuan.remain_amount].min if item and tuan.tp == 1
    self
  end
  #############团购操作结束###############
  
  #加城市算邮费
  def total(city=nil)
    @total = @items.inject(0){|total,item| total+= item.sum.to_f}
    @total = @total+fright_fee(city) if city and self.need_fright?
    if @coupon
      @total -= @coupon.coupon_category.money
    end
    @total -= @using_balance
    return 0 if @total < 0
    @total
  end
  
  def fright_fee(city)
    return 0 if items_weight == 0
    return city.fright_fee+(self.over_weight)*city.add_on_fright_fee
    return 0
  end
  
  def to_s
    return @items.collect{|item| [item.tp,item.obj_id, item.amount].join(',')}.join('|')
  end
  
  
  def need_fright?
    return true if @items.select{|item| item.tp == "tuan" and item.tuan.need_fright? and item.amount < (item.tuan.free_fright_amount||0)}.present?
    return true if @items.select{|item| item.tp == "na" and item.obj.profile.weight > 0.01}.present?
    return false
  end
  
  private 
  def parse_data(data)
    items=data.split('|')
    for item in items
      tp,id,amount =  item.split(',')
      begin
        @items << Item.new(id, amount, tp)
      rescue => e
        puts "读取购物车数据时发生错误："+e.inspect.to_s
      end
    end
  end
end
