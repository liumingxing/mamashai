class Spot < ActiveRecord::Base
  belongs_to :post
  belongs_to :province
  belongs_to :city
  belongs_to :user,:counter_cache => true
  belongs_to :spot_tag,:counter_cache => true
    
  validates_presence_of :name,:message=>APP_CONFIG['error_presence_spot']
  validates_uniqueness_of :name,:message=>APP_CONFIG['error_uniqueness_spot'],:scope=>:is_hide
  validates_presence_of :province_id
  validates_presence_of :city_id
  
  def self.find_spot_posts(user,params,follow_user_ids=[])
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.spot_id is not null"])
    includes = [:user,:forward_post,:forward_user,:spot,:blog_url,:age]
    order_str = "posts.created_at desc"
    order_str = "posts.comments_count desc" if params[:tp]=='hot'
    if params[:good]=='good'
      sqls << Post.send(:sanitize_sql,['posts.rate > 5']) 
      order_str = "posts.rate desc"
      order_str = "posts.created_at desc" if params[:tp]=='recent'
    end
    sqls << Post.send(:sanitize_sql,['posts.user_id=?',user.id])  if params[:action]=='my'
    sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])  if params[:action]=='follows'
    sqls << Post.send(:sanitize_sql,['spots.spot_tag_id=?',params[:tag_id]])  if params[:tag_id].present?
    sqls << Post.send(:sanitize_sql,['spots.province_id=?',params[:province_id]])  if params[:province_id].present?
    return Post.paginate(:per_page => 25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>includes,:order =>order_str)
  end
  
  def self.find_side_spots_posts(user,tp,follow_user_ids=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.spot_id is not null"])
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
  
end
