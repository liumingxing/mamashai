class GouBrand < ActiveRecord::Base
  has_many :gous, :dependent => :delete_all
  upload_column :logo , :versions => {:thumb255=>"c255x255",:thumb90=>"90x90",:thumb16=>"c16x16"}
  upload_column :banner
  has_many :articles, :foreign_key => :gou_brand_article_id, :dependent => :delete_all
  has_one  :article, :foreign_key => :gou_brand_story_id, :dependent => :destroy
  has_many :tuan_comments, :dependent => :delete_all
  belongs_to :subject
  
  named_scope :publish, :conditions => ['gou_brands.logo IS NOT NULL']
  named_scope :recommand, :conditions => ['gou_brands.logo IS NOT NULL'], :order=>"gou_brands.rate desc,gou_brands.hit_count desc"
  
  validates_presence_of(:name, :message => "商品品牌名称不能为空")
#  validates_presence_of(:cradle, :message => "商品品牌发源地不能为空")
  
  def self.set_gou_brand_rate(gou_brand)
    rates_count = gou_brand.rates_count + 1
    rate_sum = gou_brand.tuan_comments.all(:conditions => ['tuan_comments.rate is not NULL and tuan_comments.user_id is not NULL']).sum{|comment| comment.rate * 2 }
    gou_brand.update_attributes(:rate => (rate_sum/rates_count*10).round/10.0, :rates_count=>rates_count)
  end
  
  def self.delete_gou_brand_rate(gou_brand,comment) 
    if gou_brand.rates_count <= 1
      gou_brand.update_attributes(:rate=>0,:rates_count=>0)
    else
      rates_count = gou_brand.rates_count - 1
      rate_sum = gou_brand.tuan_comments.all(:conditions => ['tuan_comments.rate is not null and tuan_comments.user_id is not NULL and id <> ?',comment.id]).sum{|comment| comment.rate * 2 }
      gou_brand.update_attributes(:rate=>(rate_sum/rates_count*10).round/10.0,:rates_count=>rates_count)
    end
  end
  
#  def self.calculate_rate_and_values(gou_brand, comment, rates_count, type)
#    grade_labels = GouCategory.grade_labels(gou_brand)
#    return if grade_labels.blank?
#    values = {}
#    comments = gou_brand.tuan_comments if type == 1
#    comments = TuanComment.all(:select=>"rate,value_1,value_2,value_3,value_4,value_5,tuan_id",:conditions=>['gou_brand_id=? and rate is not null and id <> ?',gou_brand.id,comment.id]) if type == 2
#    grade_labels.each do |label|
#      values.merge!({"value_#{label[0]}" => comments.collect{|t| t}.sum{|gou_brand_comment| (gou_brand_comment.send("value_#{label[0]}")||0)*2}})
#    end
#    amount_rate = 0
#    values.each do |key, value|
#      gou_brand.update_attribute(key, (value/rates_count*10).round/10.0)
#      amount_rate += value
#    end
#    gou_brand.update_attributes(:rate => (amount_rate/rates_count/(grade_labels.length).to_i*10).round/10.0, :rates_count=>rates_count)
#  end 
  
  
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
  
  def self.create_brand(name)
    brand =  GouBrand.last(:conditions=>["gou_brands.name=?",name])
    return brand if brand
    brand = GouBrand.new(:name=>name) 
    subject = ::Subject.new(:name=>(name+"粉丝群"),:content=>"这里是"+name+"粉丝群。",:user_id=>::User.mms_user_id,:logo=>DEFAULT_LOGO)
    brand.subject = subject
    brand.save
    return brand
  end
  
end
