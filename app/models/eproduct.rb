class Eproduct < ActiveRecord::Base
  belongs_to :eproduct_category,:counter_cache => true
  belongs_to :eproduct_tag,:counter_cache => true
  belongs_to :post
  belongs_to :user,:counter_cache => true
#  has_many :tuan_comments, :dependent => :delete_all
  
  validates_presence_of :name,:message=>'请输入商品名称'
  validates_numericality_of :price, :message => "商品价格必须为数字"
#加上logo的判断，product的logopost.logo
  upload_column :logo,:process => '120x120', :versions => { :thumb75 => "c75x75", :thumb48 => "48x48" }
  before_create :validate_link
  
  def self.find_eproduct_posts(user,params,follow_user_ids=[])
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.eproduct_id is not null"])
    includes = [:user,:forward_post,:forward_user,:eproduct,:blog_url,:age]
    order_str = "posts.created_at desc"
    order_str = "posts.comments_count desc" if params[:tp]=='hot'
    if params[:good]=='good'
      sqls << Post.send(:sanitize_sql,['posts.rate > 5']) 
      order_str = "posts.rate desc"
      order_str = "posts.created_at desc" if params[:tp]=='recent'
    end
    sqls << Post.send(:sanitize_sql,['posts.user_id=?',user.id])  if params[:action]=='my' or params[:action]=='new_eproduct' or params[:action]=='create_eproduct'
    sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])  if params[:action]=='follows'
    sqls << Post.send(:sanitize_sql,['eproducts.eproduct_tag_id=?',params[:tag_id]])  if params[:tag_id].present?
    sqls << Post.send(:sanitize_sql,['eproducts.eproduct_tag_id >= ? and eproducts.eproduct_tag_id <= ?',13,22])  if params[:controller]=='event'
    
    if params[:price_range]
      price_range = params[:price_range].split('-')
      if price_range.count == 2
        sqls << Post.send(:sanitize_sql,['eproducts.price between ? and ?',params[:price_range].split('-')[0],params[:price_range].split('-')[1]])  if params[:price_range].present?
      else
        sqls << Post.send(:sanitize_sql,['eproducts.price > ?',price_range[0]])  if params[:price_range].present?
      end
    end  
    return Post.paginate(:per_page => 25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>includes,:order =>order_str)
  end
  
  def self.find_side_eproducts_posts(user,tp,follow_user_ids=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.eproduct_id is not null"])
    includes = [:user,:forward_post,:forward_user,:blog_url,:age] 
    limit = 7
    if tp == 'good'
      order_str = "posts.rate desc"
      sqls << Post.send(:sanitize_sql,["posts.rate > 5"]) 
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end 
    if tp == 'hot'
      order_str = "posts.comments_count desc"
      sqls << Post.send(:sanitize_sql,["comments_count > 0"])
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    return []
  end
  
  def self.set_eproduct_rate(eproduct)
    rates_count = eproduct.rates_count + 1
    calculate_rate_and_values(eproduct, nil, rates_count, 1)
  end
  
  def self.delete_eproduct_rate(eproduct,comment) 
    if eproduct.rates_count <= 1
      eproduct.update_attributes(:rate=>0,:rates_count=>0, :value_1 => nil, :value_2 => nil, :value_3 => nil, :value_4 => nil, :value_5 => nil)
    else
      rates_count = eproduct.rates_count - 1
      calculate_rate_and_values(eproduct, comment, rates_count, 2)
      #      sum = TuanComment.find(:all,:conditions=>['tuan_id=? and rate is not null and id <> ?',tuan.id,comment.id]).sum{|item| item.rate * 2 } 
      #      tuan.update_attributes(:rate=>(sum/rates_count*10).round/10.0,:rates_count=>rates_count)
    end
  end
  
  def self.calculate_rate_and_values(eproduct, comment, rates_count, type)
    grade_labels = EproductCategory.grade_labels(eproduct)
    return if grade_labels.blank?
    values = {}
    comments = eproduct.tuan_comments if type == 1
    comments = TuanComment.all(:select=>"rate,value_1,value_2,value_3,value_4,value_5,tuan_id",:conditions=>['eproduct_id=? and rate is not null and id <> ?',eproduct.id,comment.id]) if type == 2
    grade_labels.each do |label|
      values.merge!({"value_#{label[0]}" => comments.collect{|t| t}.sum{|eproduct_comment| (eproduct_comment.send("value_#{label[0]}")||0)*2}})
    end
    amount_rate = 0
    values.each do |key, value|
      eproduct.update_attribute(key, (value/rates_count*10).round/10.0)
      amount_rate += value
    end
    eproduct.update_attributes(:rate => (amount_rate/rates_count/(grade_labels.length).to_i*10).round/10.0, :rates_count=>rates_count)
  end
  
  
  private
  
  def validate_link
    unless self.link.match(/^https?:\/\/\w+/)
      self.link = nil
    end
  end
end
