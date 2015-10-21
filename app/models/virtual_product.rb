class VirtualProduct < ActiveRecord::Base
  belongs_to :tuan
  has_many :virtual_product_logs, :dependent => :delete_all
  validates_presence_of :tuan_id,:name,:tp,:message=>"不能为空"
  validates_uniqueness_of :code,:message=>"不能重复",:if=>Proc.new{|product| product.code.present?}
  
  STATES = {:new_product=>"未出售",:selling=>"出售中",:sold_out=>"已卖光"} 
  
  state_machine :initial => :new_product do
    state :selling      #出售中
    state :sold_out     #已卖光
    
    #出售虚拟商品
    event :sell do
      transition :new_product => :selling
    end
    
    #此优惠券人数已凑齐，停止出售
    event :sell_out do
      transition :selling => :sold_out 
      transition :new_product => :sold_out 
    end
    
  end
  
  def generate_random_code(order_item_id)
    encrypt_order_item_id = MamashaiTools::TextUtil.encrypt_user_id(order_item_id) #加密后的order_item_id
    char = (('1'...'9').to_a+('A'..'Z').to_a - ['O','I']).rand.to_s
    return (char+encrypt_order_item_id).chars.sort_by{rand}.to_s
  end
  
  def generate_random_password(user_id,order_item_id)
    return unless self.tp==2
    encrypt_user_id = MamashaiTools::TextUtil.encrypt_user_id(user_id) #加密后的用户id
    order_item_id = order_item_id.to_s #订单项id
    time = Time.now.strftime("%m%Y%d%M%S%H") #时间
    rand = rand(999).to_s #随机数
    tp = 'MMSCODE' #
    char = (('1'...'9').to_a+('A'..'Z').to_a - ['O','I']).rand.to_s
    long_str = tp+rand+encrypt_user_id+order_item_id+time
    str = long_str.crypt('mms').upcase
    return str.gsub(/^[A-Z0-9]/,char)
  end
  
  def calculate_end_time
    return self.end_time if self.end_time.present?
    return self.begin_time+self.limit_time if self.begin_time.present? and self.limit_time.present?
    return Date.today + self.limit_time
  end
  
end
