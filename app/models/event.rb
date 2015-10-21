class Event < ActiveRecord::Base
  belongs_to :user,:counter_cache => true
  belongs_to :post
  belongs_to :province
  belongs_to :city
  belongs_to :spot
  belongs_to :event_tag,:counter_cache => true
  
  
  has_one :event_fee,:dependent => :destroy
  has_many :event_pictures,:dependent => :delete_all
  has_many :event_pays,:dependent => :delete_all,:order=>'event_pays.created_at asc'
  
  has_many :posts
  has_many :event_users,:dependent => :delete_all
  
  validates_presence_of :name
  validates_presence_of :start_at
  validates_presence_of :user_id
  
  # org event has a post_id share event post_id is null
  
  named_scope :current,:conditions=>['events.start_at > ? and events.cancel_reason is null',Time.now],:order=>'events.id desc'
  named_scope :history,:conditions=>['events.start_at < ? and events.cancel_reason is null',Time.now],:order=>'events.id desc'
  
  
  def is_end
   (self.start_at < Time.now) or self.cancel_reason.present? # or (self.limit_num && self.event_users_count >= self.limit_num)
  end 
  
  def is_can_delete(post)
   (self.post_id.blank?) or (self.post_id == post.id && self.posts_count <= 1 && self.event_users_count == 0 )
  end
  
  ################### create  #####################
  
  def self.create_event(params,user)
    age_ids = params[:age_ids].collect{|m| m[0] if m[1]=='1'}.compact
    event = Event.new(params[:event])
    event.user_id = user.id
    event.age_ids = age_ids.join(',')
    event.save
    if event.spot
      spot = event.spot
      event.city_id = spot.city_id
      event.province_id = spot.province_id
      event.longitude = spot.longitude
      event.latitude = spot.latitude
      event.location = spot.location
      event.save
    end
    unless event.errors.empty?
      return event
    end 
    event
  end
  
  
  ############### find ######################
  
  def self.find_user_join_events(user)
    Event.find(:all,:conditions=>['user_id=?',user.id])
  end
  
  ############## side find ####################
  
  def self.find_sidebar_posts(tp,user,follow_user_ids=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    includes = [:user,:forward_post,:forward_user,:blog_url,:age]
    order_str = "posts.created_at desc"
    limit = 2
    if tp == 'my_org'
      sqls << Post.send(:sanitize_sql,["posts.user_id = ?",user.id]) 
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'my_signup'
      sqls << Post.send(:sanitize_sql,["event_users.user_id=?",user.id])
      joins_sql = "inner join events on posts.id = events.post_id inner join event_users on event_users.event_id = events.id"
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:joins=>joins_sql,:include=>includes,:order=>order_str)
    end
    if tp == 'my_share'
      sqls << Post.send(:sanitize_sql,["posts.user_id = ?",user.id]) 
      joins_sql = "inner join events on events.id = posts.event_id and (events.post_id <> posts.id or events.post_id is null)"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'recent_org'
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'recent_share'
      joins_sql = "inner join events on events.id = posts.event_id and (events.post_id <> posts.id or events.post_id is null)"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'hot_org'
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>"posts.score desc")
    end
    if tp == 'hot_signup'
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:joins=>joins_sql,:include=>includes,:order=>"events.event_users_count desc")
    end
    if tp == 'hot_share'
      joins_sql = "inner join events on events.id = posts.event_id and (events.post_id <> posts.id or events.post_id is null)"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>"posts.score desc")
    end
    if tp == 'follow_org'
      sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>"posts.score desc")
    end
    if tp == 'follow_signup'
      sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])
      joins_sql = "inner join events on posts.id = events.post_id"
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:joins=>joins_sql,:include=>includes,:order=>"posts.created_at desc")
    end
    return []
  end
  
  ################## find posts ####################
  
  def self.find_event_posts(user,params)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and events.cancel_reason is null"])
    if params[:history]=='history'
      sqls << Post.send(:sanitize_sql,["events.start_at < ? ",Time.now]) 
    else
      sqls << Post.send(:sanitize_sql,["events.start_at > ? ",Time.now]) 
    end
    
    date = Date.today
    if params[:tp]=='today'
      sqls << Post.send(:sanitize_sql,["events.start_at > ? and events.start_at < ?",date,date+1]) 
    elsif params[:tp]=='week' 
      sqls << Post.send(:sanitize_sql,["events.start_at > ? and events.start_at < ?",date,date+7]) 
    elsif params[:date].present?
      date = Date.parse(params[:date])
      sqls << Post.send(:sanitize_sql,["events.start_at > ? and events.start_at < ?",date,date+1]) 
    end 
    
    if params[:tag_id].present?
      sqls << Post.send(:sanitize_sql,["events.event_tag_id = ?",params[:tag_id]]) 
    end
    
    if params[:province_id].present?
      sqls << Post.send(:sanitize_sql,["events.province_id = ?",params[:province_id]]) 
    end
    order_str = "posts.created_at desc"
    order_str = "events.event_users_count desc" if params[:tp] == 'hot'
    joins_sql = "inner join events on posts.id = events.post_id"
    Post.paginate(:per_page => 25,:joins=>joins_sql,:select=>'posts.*',:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>[:user,:forward_post,:forward_user,:blog_url,:age,:category],:order => order_str)
  end
  
  def self.find_my_event_posts(user,params)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    if params[:tp]=='signup'
      sqls << Post.send(:sanitize_sql,["event_users.user_id=?",user.id])
    else
      sqls << Post.send(:sanitize_sql,["posts.user_id=?",user.id])
    end
    joins_sql = "inner join events on posts.id = events.post_id" 
    joins_sql = "inner join events on posts.id = events.post_id inner join event_users on event_users.event_id = events.id" if params[:tp]=='signup'
    Post.paginate(:per_page => 25,:joins=>joins_sql,:select=>'posts.*',:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>[:user,:forward_post,:forward_user,:blog_url,:age,:category],:order => "posts.created_at desc")
  end 
  
  def self.find_follows_event_posts(user,params,follow_user_ids)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids]) 
    joins_sql = "inner join events on posts.id = events.post_id"  
    Post.paginate(:per_page => 25,:joins=>joins_sql,:select=>'posts.*',:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>[:user,:forward_post,:forward_user,:blog_url,:age,:category],:order => "posts.created_at desc")
    
  end
  
end
