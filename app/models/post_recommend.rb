class PostRecommend < ActiveRecord::Base
  belongs_to :user
  belongs_to :post,:counter_cache => true
  
  validates_presence_of :user_id
  validates_presence_of :post_id
  
  def self.create_post_recommend(post,user,params)
    return if post.user_id  == user.id 
    post_recommend = PostRecommend.new(params[:post_recommend])
    ActiveRecord::Base.transaction do
      unless PostRecommend.find_by_user_id_and_post_id(user.id,post.id)
        post_recommend.user_id = user.id
        post_recommend.post_id = post.id
        post_recommend.save
        # MamashaiTools::ToolUtil.add_unread_infos(:create_post_recommend,{:user=>post.user})
      end  
    end 
    if post.post_recommends_count == 0
      User.update_all(["info_count = info_count + 1"],["id=?",post.user_id])
    end
    post_recommend
  end
  
  def self.delete_post_recommend(params,user)
    ActiveRecord::Base.transaction do
      post_recommend = PostRecommend.find_by_post_id_and_user_id(params[:id],user.id)
      post = post_recommend.post
      post_recommend.destroy
    end
  end
  
  
  ######################## find #########################
  
  def self.find_info_posts(user,params) 
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.post_recommends_count > 0"])
    unless params[:age].blank?
      sqls << Post.send(:sanitize_sql,["posts.age_id = ?",params[:age]])
    end
    unless params[:tag].blank?
      sqls << Post.send(:sanitize_sql,["posts.tag_id = ?",params[:tag]])
    end
    unless params[:date].blank?
      sqls << Post.send(:sanitize_sql,["posts.created_at > ?",params[:date]])
    end
    order_str = "posts.created_at desc"
    order_str = params[:order] unless params[:order].blank?
    includes = [:user,:forward_post,:forward_user,:event,:blog_url,:age,:category]
    return Post.paginate(:per_page => 25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page],:include=>includes,:order =>order_str )
  end 
  
  def self.find_2_side_info_posts(user,tp,follow_user_ids=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.post_recommends_count > 0"])
    includes = [:user,:forward_post,:forward_user,:blog_url,:age]
    order_str = "posts.created_at desc"
    limit = 2
    if tp == 'my_infos'
      sqls << Post.send(:sanitize_sql,["posts.user_id = ?",user.id]) 
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'my_recommends'
      sqls << Post.send(:sanitize_sql,["post_recommends.user_id = ?",user.id])
      joins_sql = "inner join post_recommends on posts.id = post_recommends.post_id"
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:joins=>joins_sql,:include=>includes,:order=>order_str)
    end
    if tp == 'follows_infos'
      sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'follows_recommends'
      sqls << Post.send(:sanitize_sql,["post_recommends.user_id in (?)",follow_user_ids])
      joins_sql = "inner join post_recommends on posts.id = post_recommends.post_id"
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:joins=>joins_sql,:include=>includes,:order=>"post_recommends.created_at desc")
    end
    if tp == 'recent'
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>order_str)
    end
    if tp == 'hot'
      return Post.find(:all,:limit=>limit,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes,:order=>"posts.rate desc")
    end
    []
  end
  
  
end
