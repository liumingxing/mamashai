# -*- coding: utf-8 -*-
class Tuan < ActiveRecord::Base
  belongs_to :tuan_category, :counter_cache => true
  belongs_to :tuan_category_temp, :counter_cache => true
  belongs_to :tuan_website, :counter_cache => true
  has_many :tuan_comments, :dependent => :delete_all
  has_many :favorite_tuan, :dependent => :delete_all
  has_many :virtual_products, :dependent => :delete_all
  belongs_to :gou_category
  upload_column :logo ,:process => '460x258', :versions => {:thumb280=>"c280x160", :thumb205=>"c200x125",:thumb97 => "c97x57"}
  
  validates_presence_of :tuan_website_id,:address,:begin_time,:end_time,:content,:origin_price,:current_price,:message => '不能为空'
  validates_presence_of :url, :if => Proc.new{|t| t.tp<=0}
  validates_presence_of :logo, :if => Proc.new{|t| t.tp>0},:message=>'不能为空'
  validates_associated :tuan_website, :message => "无此网站"
  validates_associated :tuan_category, :message => "无此分类"
  validates_numericality_of :current_price,:origin_price, :person_amount, :message => "必须为数字"
  #  validates_inclusion_of :supplier_code, :in => Supplier.all(:select=>"code").map(&:code), :if=>Proc.new{|tuan| tuan.tp>0},:allow_nil=>true,:allow_blank=>true, :message => "请核查供应商编码是否存在"
  
  before_save :set_discount,:set_save_money
  #  before_save :check_supplier_code, :if=>Proc.new{|tuan| tuan.tp>0}
  after_create :generate_url
  
  #named_scope :mms, :conditions=>"tuans.id in (#{(TuanMama.find(:all).collect{|t| t.tuan_id}<<-1).join(',')})" #:conditions=>["tuans.tp >= ?",1]
  named_scope :mms, :conditions=>["tuans.tp >= ?",1]
  named_scope :others_tuan, :conditions => ["tuans.tp <= ?", 0]
  named_scope :current, :conditions => ["tuans.current_key = ?", true]
  named_scope :not_begin, :conditions => ["tuans.begin_time > ?", Time.now]
  named_scope :ready, lambda { |time|{ :conditions => ["tuans.begin_time <= :now and tuans.end_time >= :now",{:now=>time}] }}
  named_scope :ended, lambda { |time|{ :conditions => ["tuans.end_time < ?",time] }}
  named_scope :not_ended, lambda { |time|{ :conditions => ["tuans.end_time >= ?",time] }}
  
  STATES=["未开始","抢购中","已结束","已卖光"]
  SALE_TYPES = [[1,'正常团购'],[2,'-1元活动'],[3,'0元团购']]
  
  def tuan_url
    url = self.url
    url = "http://www.letyo.com/"+url unless url =~ %r{http://www.letyo.com/}
    return url
  end
  
  def self.cities
    %w{北京 上海 杭州 南昌 长沙 重庆 南宁 福州 合肥 厦门 西安 济南 成都 郑州 武汉 石家庄 天津 青岛 南京 广州 深圳}
  end
  
  def self.mms_tuan_type
    SALE_TYPES
  end
  
  def mms_tuan_type
    tp = self.tp
    return "非妈妈晒" if tp<=0
    return SALE_TYPES[tp-1][1]
  end
  
#  def self.calculate_rate(tuan)
#    grade_labels = EproductCategory.grade_labels(tuan)
#    if grade_labels.blank?
#      return 0
#    else
#      sum = grade_labels.inject(0) {|sum, label| sum += comment.send("value_#{label[0]}") unless comment.send("value_#{label[0]}").blank?}
#      rate = sum / grade_labels.size
#    end
#  end
  
  def self.set_tuan_rate(tuan) 
    rates_count = tuan.rates_count + 1
#    calculate_rate_and_values(tuan, nil, rates_count, 1)
    sum = TuanComment.find(:all,:conditions=>['tuan_comments.tuan_id=? and tuan_comments.rate is not null',tuan.id]).sum{|item| item.rate * 2 } 
    tuan.update_attributes(:rate=>(sum/rates_count*10).round/10.0,:rates_count=>rates_count)
  end
  
  def self.delete_tuan_rate(tuan,comment) 
    if tuan.rates_count <= 1
      tuan.update_attributes(:rate=>0,:rates_count=>0)
    else
      rates_count = tuan.rates_count - 1
#      calculate_rate_and_values(tuan, comment, rates_count, 2)
      sum = TuanComment.find(:all,:conditions=>['tuan_comments.tuan_id=? and tuan_comments.rate is not null and id <> ?',tuan.id,comment.id]).sum{|item| item.rate * 2 } 
      tuan.update_attributes(:rate=>(sum/rates_count*10).round/10.0,:rates_count=>rates_count)
    end
  end
  
#  def self.calculate_rate_and_values(tuan, comment, rates_count, type)
#    grade_labels = GouCategory.grade_labels(tuan)
#    return if grade_labels.blank?
#    values = {}
#    comments = tuan.tuan_comments if type == 1
#    comments = TuanComment.all(:select=>"rate,value_1,value_2,value_3,value_4,value_5,tuan_id",:conditions=>['tuan_id=? and rate is not null and id <> ?',tuan.id,comment.id]) if type == 2
#    grade_labels.each do |label|
#      values.merge!({"value_#{label[0]}" => comments.collect{|t| t}.sum{|tuan_comment| (tuan_comment.send("value_#{label[0]}")||0)*2}})
#    end
#    amount_rate = 0
#    values.each do |key, value|
#      tuan.update_attribute(key, (value/rates_count*10).round/10.0)
#      amount_rate += value
#    end
#    tuan.update_attributes(:rate => (amount_rate/rates_count/(grade_labels.length).to_i*10).round/10.0, :rates_count=>rates_count)
#  end
  
  def tuan_state
    return STATES[3] unless self.remain?
    begin_time = self.begin_time
    end_time = self.end_time
    now = Time.now
    if now < begin_time
      return STATES[0]
    elsif now >= begin_time and now <= end_time
      return STATES[1]
    else
      return STATES[2]
    end
  end
  
  def self.find_by_cond(params, cond, default_order_by)
    order_by = default_order_by
    page = params[:page] || 1
    case params[:cond]
      when "order-by-new"
      order_by = "begin_time DESC"      
      when "order-by-hotornot"
      order_by = "buyers_count DESC"
      when "order-by-buyer"
      order_by = "person_amount DESC"
      when "order-by-endtime"
      order_by = "end_time ASC"
      when "order-by-dime"
      order_by = "discount ASC"
      when "order-by-cutprice"
      order_by = "save_money DESC"
      when "order-by-price"
      order_by = "current_price ASC"
    end
    return Tuan.paginate(:per_page => params[:per_page]||10,:page => page, :conditions => Tuan.merge_conditions(*cond), :include => [:tuan_website], :order => order_by)
  end
  
  def hot_type
    hot = self.person_amount
    str = "green"
    if hot < 400
      str = "green"
    elsif hot>=400 and hot <1000
      str = "yellow"
    else
      str = "red"
    end
    return str
  end
  
  def catch_image(url)
    image_name = url.split('-')[-1]
    filename = File.join(RAILS_ROOT,"tmp","tuans",image_name)
    `curl -o #{filename} #{url}`
    file = File.open(filename)
    file
  end
  
  def person_amount_view(now)
    return 425 if self.id == 23685
    return 50+OrderItem.count(:conditions=>["orders.state=? and order_items.item_id=?","has_paid",10172],:joins=>"inner join orders on order_items.order_id=orders.id") if self.id==10172
    show_amount = 327
    return self.person_amount if self.tp <=0 or [463,461,132,82].include?(self.id) or self.current_price < 5 or self.max_amount
    return self.person_amount+show_amount if self.person_amount>show_amount
    time = ((now-self.begin_time)/60/10).round 
    return 0 if time < 0
    amount = self.person_amount+time
    return amount>show_amount ? show_amount+self.person_amount : amount
  end
  
  def need_fright?
    self.fright_money>0
  end
  
  def free_fright?
    self.fright_money == 0.to_f and self.tp ==1
  end
  
  
  def remain?
    return true unless self.max_amount
    return (self.max_amount - self.person_amount) > 0
  end
  
  def remain_amount
    return (self.max_amount - self.person_amount) if self.max_amount
    return 9999999
  end
  
  def can_back_money?
    return true if self.back_money and self.back_money > 0
    return false
  end
  
  private
  
  def set_discount
    self.discount = ((self.current_price/self.origin_price)*100).round/10.0
  end
  
  def set_save_money
    self.save_money = ((self.origin_price - self.current_price)*100).round/100.0
  end
  
  def generate_url
    self.update_attributes(:url=>("/tuan/mama/"+self.id.to_s))  unless self.url
  end
  
  #  def check_supplier_code
  #    codes = Supplier.all(:select=>"code").map(&:code)
  #    @errors.add(:supplier_code,"请核查供应商编码是否存在") if self.supplier_code.present? and !codes.include?(self.supplier_code)
  #  end
  
end
