class Coupon < ActiveRecord::Base
  belongs_to :user
  belongs_to :coupon_category, :counter_cache => true
  validates_presence_of(:money, :message => "金额不能为空")
  validates_numericality_of(:money, :greater_than_or_equal_to => 0, :message => "金额必须为数字")
  validates_presence_of(:limit_time, :message => "使用期限不能为空")
  
  before_create :trigger_score_event
  
  named_scope :expired, lambda { |time|{ :conditions => ["coupons.limit_time < ?",time] }}
  named_scope :unexpired, lambda { |time|{ :conditions => ["coupons.limit_time > ?",time] }}
  named_scope :used,:conditions=>["coupons.state=?",'has_used']
  named_scope :unused,:conditions=>["coupons.state=?",'new_coupon']
  named_scope :tuan,:conditions=>["coupon_categories.tp = ?",1],:include=>[:coupon_category]
  named_scope :book,:conditions=>["coupon_categories.tp = ?",2],:include=>[:coupon_category]
  
  COUPON_STATES = {:new_coupon=>'未使用',:has_used=>'已使用',:has_expired=>'已过期', :sent=>'已发货', :received => '已收货'}
  #### 具体积分需要确定
  
  LIMIT_TIME = 365*24*60*60
  
  state_machine :initial => :new_coupon do
#    state :has_enabled  #已启用
    state :has_used     #已使用
    state :has_expired  #已过期
    state :sent         #已发送
    state :received     #已收到
    
    
    #发送礼品
    event :send_present do
      transition :new_coupon => :sent
    end
    
    #收到礼品
    event :receive_present do
      transition :sent => :received
    end
    
    #使用优惠券
    event :use_coupon do
      transition :new_coupon => :has_used
    end
    
    #优惠券过期
    event :coupon_expired do
      transition :new_coupon => :has_expired
    end
    
    #优惠券取消
    event :cancel do
      transition :has_used => :new_coupon
    end
    
  end
  
  def self.exchange_coupon(user,coupon_category)
    return unless coupon_category and user and user.score >= coupon_category.score
    coupon = Coupon.new
    coupon.user = user
    coupon.coupon_category = coupon_category
    coupon.money = coupon_category.money
    coupon.score = coupon_category.score
    coupon.limit_time = Time.now+coupon_category.limit_time
    return coupon if coupon.save #and user.save
    return
  end

  def state_type
    state = self.state
    return '已过期' if self.limit_time < Time.now
    COUPON_STATES[state.to_sym]
  end
  
  private
  
  def trigger_score_event
    category = self.coupon_category
    event_name = "exchange_coupon_category_"+category.id.to_s
    Mms::Score.trigger_event(event_name.to_sym, category.log, category.score*(-1), 1, {:user => self.user})
  end

end
