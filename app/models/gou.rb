#require 'rmmseg'
#require 'rmmseg/ferret'
class Gou < ActiveRecord::Base
  belongs_to :gou_category, :counter_cache => true
  #belongs_to :gou_brand, :counter_cache => true
  has_many :tuan_comments, :dependent => :delete_all
  has_many :gou_gou_sites, :dependent => :destroy
  has_many :gou_sites, :through => :gou_gou_sites, :dependent => :destroy
  has_many :gou_visits
  belongs_to :gou_site, :foreign_key=>"site_id"
  belongs_to :user
  has_one :profile, :class_name=>"NaProfile"
  upload_column :logo , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
  
  #acts_as_ferret :fields=>[:cate, :name]
  #acts_as_ferret(:reindex_batch_size=>10000, 
  #      :fields => {:cate=>{:store=>:yes,:index=>:yes}, :name=>{:store=>:yes, :index=>:yes}}, 
  #      :ferret=>{:analyzer=>RMMSeg::Ferret::Analyzer.new {|tokenizer| Ferret::Analysis::LowerCaseFilter.new(tokenizer)}}
  #      )

  validates_numericality_of(:price, :greater_than_or_equal_to => 0, :message => "价格必须大于或等于0")
  validates_presence_of(:name, :message => "商品名称不能为空")
  #  validates_presence_of(:logo, :message => "商品图片不能为空")
  #validates_presence_of(:content, :message => "商品介绍不能为空")
  validates_presence_of(:price, :message => "商品价格不能为空")
  #validates_presence_of(:standard, :message => "商品规格不能为空")
  #  validates_presence_of(:for_ages, :message => "商品适用年龄不能为空")
  
  named_scope :publish, :conditions => ['logo is not null']
  named_scope :na, :conditions=>"tp='na'"
  
  def gou_brand
    GouBrand.find(:first, :conditions=>"name = '#{self.brand.gsub("'", "")}'")
  end
  
  def self.set_gou_rate(gou)
    rates_count = gou.rates_count + 1
    rate_sum = gou.tuan_comments.all(:conditions => ['tuan_comments.rate is not NULL and tuan_comments.user_id is not NULL']).sum{|comment| comment.rate * 2 }
    gou.update_attributes(:rate => (rate_sum/rates_count*10).round/10.0, :rates_count=>rates_count)
  end
  
  def self.delete_gou_rate(gou,comment) 
    if gou.rates_count <= 1
      gou.update_attributes(:rate=>0,:rates_count=>0)
    else
      rates_count = gou.rates_count - 1
      rate_sum = gou.tuan_comments.all(:conditions => ['tuan_comments.rate is not null and tuan_comments.user_id is not NULL and id <> ?',comment.id]).sum{|comment| comment.rate * 2 }
      gou.update_attributes(:rate=>(rate_sum/rates_count*10).round/10.0,:rates_count=>rates_count)
    end
  end
  
  def comment_count
    TuanComment.count :conditions=>"kind=1 and kind_id = #{self.id}"
  end
  
  def self.calculate_rate_and_values(gou, comment, rates_count, type)
#    grade_labels = GouCategory.grade_labels(gou)
#    return if grade_labels.blank?
#    values = {}
#    comments = gou.tuan_comments if type == 1
#    comments = TuanComment.all(:select=>"rate,value_1,value_2,value_3,value_4,value_5,tuan_id",:conditions=>['gou_id=? and rate is not null and id <> ?',gou.id,comment.id]) if type == 2
#    grade_labels.each do |label|
#      values.merge!({"value_#{label[0]}" => comments.collect{|t| t}.sum{|gou_comment| (gou_comment.send("value_#{label[0]}")||0)*2}})
#    end
#    amount_rate = 0
#    values.each do |key, value|
#      gou.update_attribute(key, (value/rates_count*10).round/10.0)
#      amount_rate += value
#    end
#    gou.update_attributes(:rate => (amount_rate/rates_count/(grade_labels.length).to_i*10).round/10.0, :rates_count=>rates_count)
     
  end
  
  state_machine :initial => :unpublish do
    state :unpublish
    state :publish
    
    event :publish do
      transition :unpublish => :publish
    end
    
    event :unpublish do
      transition :publish => :unpublish
    end
    
  end
  
end
