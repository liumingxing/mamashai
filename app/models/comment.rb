class Comment < ActiveRecord::Base
  before_create :make_post_user_id
  before_create :save_to_sina
  before_create :save_to_tencent
  before_create :check_content
  after_create :push_aps
  after_create :add_attention
  after_create :make_score
  after_create :add_at_remind

  before_destroy :delete_remind
  
  belongs_to :user
  belongs_to :post, :counter_cache => true
  
  
#  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  
  def check_content
    return false if !self.content || self.content == ''

    return true;
  end

  def make_post_user_id
    self.post_user_id = self.post.user_id if self.post
  end

  def add_at_remind
    return if !self.post || !self.content
    
    CommentAtRemind.create(:comment_id=>self.id, :user_id=>self.post.user_id) rescue nil
    names = MamashaiTools::TextUtil.scan_atme_names(self.content)
    for name in names
      user = User.find(:first, :conditions=>["name = binary ?", name])
      if user && user.id != self.post.user_id
        CommentAtRemind.create(:comment_id => self.id, :user_id => user.id) rescue nil
      end
    end
  end

  def delete_remind
    CommentAtRemind.delete_all("tp='comment' and comment_id = #{self.id}")
  end

  def push_aps
    #Thread.new do 
      if self.post.user_id != self.user_id      #自己评论自己不推送
        MamashaiTools::ToolUtil.push_aps(self.post.user_id, "#{self.user.name}评论了您的记录：#{self.content}", {"t"=>"comment"})
      end
      names = MamashaiTools::TextUtil.scan_atme_names(self.content)
      for name in names
        user = User.find_by_name(name)
        if user
          MamashaiTools::ToolUtil.push_aps(user.id, "#{self.user.name}：#{self.content}", {"t"=>"comment"})
        end
      end
    #end
  end
  
  def make_score
    if self.post.user_id != self.user_id      #自己的评论不算分
      s = self.content
      s = s.gsub(/\[\p{Word}+\]/, 'a')
      return if s.size < 5

      UserInfo.add_comments_count(self.user_id)

      c = UserInfo.get_comments_count(self.user_id)

      if c == 5 || c == 10 || c==15
        Mms::Score.trigger_event(:make_comments, "一天评论5条记录", 1, 1, {:user => self.user})
      end
      
      #Mms::Score.trigger_event(:mobile_make_comments, "对记录进行评论", 0, 0, {:user => self.user})
        
      #if ScoreEvent.all(:limit=>6, :conditions=>"user_id = #{self.user_id} and event = 'mobile_make_comments' and created_day = '#{Date.today.to_s(:db)}'", :order=>"id desc").size == 5
      #  Mms::Score.trigger_event(:make_comments, "一天评论5条记录", 1, 1, {:cond => :by_per_day, :user => self.user})
      #end

      #if ScoreEvent.all(:limit=>11, :conditions=>"user_id = #{self.user_id} and event = 'mobile_make_comments' and created_day = '#{Date.today.to_s(:db)}'", :order=>"id desc").size == 10
      #  Mms::Score.trigger_event(:make_comments, "一天评论5条记录", 1, 1, {:user => self.user})
      #end

      #if ScoreEvent.all(:limit=>16, :conditions=>"user_id = #{self.user_id} and event = 'mobile_make_comments' and created_day = '#{Date.today.to_s(:db)}'", :order=>"id desc").size == 15
      #  Mms::Score.trigger_event(:make_comments, "一天评论5条记录", 1, 1, {:user => self.user})
      #end
    end
  end
  
  def self.set_post_rate(post) 
    if post.rates_count
      rates_count = post.rates_count + 1
    else
      rates_count = 1
    end
    sum = Comment.find(:all,:conditions=>['post_id=? and rate is not null',post.id]).sum{|item| item.rate * 2 } 
    post.update_attributes(:rate=>(sum/rates_count*10).round/10.0,:rates_count=>rates_count)
  end
  
  def self.delete_post_rate(post,comment)
    if post.rates_count <= 1
      post.update_attributes(:rate=>0,:rates_count=>0)
#      post.eproduct.update_attributes(:rate=>0) if post.eproduct
    else
      rates_count = post.rates_count - 1
      sum = Comment.find(:all,:conditions=>['post_id=? and rate is not null and id <> ?',post.id,comment.id]).sum{|item| item.rate * 2 } 
      post.update_attributes(:rate=>(sum/rates_count*10).round/10.0,:rates_count=>rates_count)
#      post.eproduct.update_attributes(:rate=>(sum/rates_count*10).round/10.0) if post.eproduct
    end
  end
  
  def self.create_comment(params,user,post)
    comment = Comment.new(params[:comment])
    ActiveRecord::Base.transaction do 
      comment.user = user
      comment.post_id = post.id
      comment.save
      return comment unless comment.errors.empty?
      set_post_rate(comment.post) if comment.rate.present?
      if params[:is_copy_post].to_s == "1" || params[:is_copy_post].to_s == "true" || params[:is_copy_post].to_s == "on" 
        if post.forward_post_id
          forward_post = post.forward_post 
          comment.content = "#{comment.content}//@#{post.user.name}:#{post.content}"
          post.update_attributes(:forward_posts_count => (post.forward_posts_count+1))
        else
          forward_post = post
        end
        post = Post.create_forward_post(comment.content,user,forward_post, params[:from])
        post.save
      end
    end
    if post.score.present?
      User.update_all(["ask_count = ask_count + 1"],["id=?",user.id])
    end
    comment
  end
  
  def self.delete_comment(comment_id,user)
    post = nil
    ActiveRecord::Base.transaction do 
      comment = Comment.find_by_id(comment_id)
      if comment && (comment.user_id == user.id || user.tp == 4 || user.tp == 10)
        post = comment.post
        delete_post_rate(post,comment) if comment.rate.present?
        comment.destroy
      end
    end
    post
  end
  
  def self.delete_post_comment(comment_id,user)
    ActiveRecord::Base.transaction do 
      comment = Comment.find(comment_id)
      if comment
        post = comment.post
        delete_post_rate(post,comment) if comment.rate.present?
        comment.destroy if (comment.user_id == user.id) or (post and post.user_id==user.id)
      end
    end
  end
  
  def self.delete_all_select_comments(comment_ids,user)
    ActiveRecord::Base.transaction do 
      comment_ids.each do |comment_id|
        Comment.delete_post_comment(comment_id,user)
      end
    end
  end
  
  ################ find ######################## 
  
  def self.find_user_posts_comments(user,params, paginate=true)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_comments_count)
#    conditions = ["(post_user_id=#{user.id} or comments.content like '回复@#{user.name}:%' or comments.content like '回复@#{user.name}：%' or comments.content like '回复#{user.name}:%')"]
#    conditions << "comments.user_id <> #{user.id}"
    conditions = ["comment_at_reminds.user_id = #{user.id}"]
    conditions << URI.decode(params[:cond]) if params[:cond]
    if paginate
      Comment.paginate(:per_page => params[:per_page]||25, :joins=>"left join comment_at_reminds on comments.id=comment_at_reminds.comment_id", :conditions=>conditions.join(' and '),:page => params[:page]||1, :include=>[:user],:order => "comments.id desc")
    else
      Comment.find(:all, :limit => params[:per_page]||25, :joins=>"left join comment_at_reminds on comments.id=comment_at_reminds.comment_id", :conditions=>conditions.join(' and '), :include=>[:user],:order => "comments.id desc")
    end
  end 
  
  def self.find_user_posts_follows_comments(user,params)
    Comment.paginate(:per_page => params[:per_page]||25,:conditions=>['posts.user_id=? and posts.score is null and comments.user_id <> ? and follow_users.user_id = ?',user.id,user.id,user.id],:joins=>"inner join posts on posts.id = comments.post_id left join follow_users on follow_users.follow_user_id = comments.user_id",:select=>'comments.*',:page => params[:page]||1,:include=>[:user],:order => "comments.id desc")
  end
  
  def self.find_user_posts_other_comments(user,params)
    Comment.paginate(:per_page => params[:per_page]||25,:conditions=>['posts.user_id=? and posts.score is null and comments.user_id <> ? and comments.user_id not in (select follow_user_id from follow_users where follow_users.user_id = ? ) ',user.id,user.id,user.id],:joins=>"inner join posts on posts.id = comments.post_id",:select=>'comments.*',:page => params[:page]||1,:include=>[:user],:order => "comments.id desc")
  end
  
  def self.find_user_comments(user,params)
    Comment.paginate(:per_page => params[:per_page]||25,:conditions=>['comments.user_id=? and posts.score is null',user.id],:page => params[:page]||1,:include=>[:user,:post],:order => "comments.id desc")
  end
  
  def self.find_post_comments(post,params)
    Comment.paginate(:per_page => params[:per_page]||25,:conditions=>['comments.post_id=?',post.id],:page => params[:page]||1,:include=>[:user],:order => "comments.id")
  end
  
  #添加提醒
  def add_attention
    MamashaiTools::ToolUtil.update_users_comment_atme_count(self.content)
    MamashaiTools::ToolUtil.add_unread_infos(:create_comment,{:post=>self.post,:post_user=>self.post.user,:comment=>self,:comment_user=>self.user})
  end
  
  #同步到新浪
  def save_to_sina
    return if !self.post.sina_weibo_id
    
    token = Weibotoken.get('sina', nil)
    user_weibo = UserWeibo.find(:first, :conditions=>"user_id = #{self.user_id} and tp = #{token.tp}")
    if !token
      token = Weibotoken.get('sina', "baby_calendar")
      user_weibo = UserWeibo.find(:first, :conditions=>"user_id = #{self.user_id} and tp = #{token.tp}")
    end
    
    text = "来自妈妈晒的评论：#{self.content}".gsub("回复@", "回复")
    if !user_weibo || (user_weibo.expire_at && user_weibo.expire_at < Time.new.to_i)
      u = User.find_by_name('妈妈晒')
      user_weibo = UserWeibo.find(:first, :conditions=>"user_id=#{u.id} and tp = 1")
      text = "来自妈妈晒用户#{self.user.name}的评论：#{self.content}" 
    end
    begin
      text = `curl -d 'comment=#{text}' -d 'id=#{self.post.sina_weibo_id}' 'https://api.weibo.com/2/comments/create.json?source=#{token.token}&access_token=#{user_weibo.access_token}'`
      json = ActiveSupport::JSON.decode(text)
      self.sina_weibo_id = json["id"]
    rescue
    end
  end
  
  #同步到腾讯
  def save_to_tencent
    return if !self.post.tencent_weibo_id
    
    begin
      if user_qq = UserQq.find(:first, :conditions=>"user_id=#{self.user.id} and tp = 2")  #绑定了妈妈晒key
        consumer = OAuth::Consumer.new(QQ_KEY, QQ_SECRET, CONSUMER_OPTIONS)
        access_token = OAuth::AccessToken.new(consumer, user_qq.access_token, user_qq.access_secret)
        res = access_token.post("http://open.t.qq.com/api/t/comment", {:content=>self.content, :reid=>self.post.tencent_weibo_id})
        res = ActiveSupport::JSON.decode(res.body)
        self.tencent_weibo_id = res["data"]["id"] if res["msg"] == "ok"
      elsif user_qq = UserQq.find(:first, :conditions=>"user_id=#{self.user.id} and tp = 3")  #绑定了辣妈日报key
        consumer = OAuth::Consumer.new('b505850710db48e5a5903515788159a1', 'be6a80c0178b2259848bd6f2c5079b3f', CONSUMER_OPTIONS)
        access_token = OAuth::AccessToken.new(consumer, user_qq.access_token, user_qq.access_secret)
        res = access_token.post("http://open.t.qq.com/api/t/comment", {:content=>self.content, :reid=>self.post.tencent_weibo_id})
        res = ActiveSupport::JSON.decode(res.body)
        self.tencent_weibo_id = res["data"]["id"] if res["msg"] == "ok"
      else #两个都没绑定
        u = User.find_by_name('妈妈晒')
        user_qq = UserQq.find(:first, :conditions=>"user_id=#{u.id}")
        consumer = OAuth::Consumer.new('b505850710db48e5a5903515788159a1', 'be6a80c0178b2259848bd6f2c5079b3f', CONSUMER_OPTIONS)
        access_token = OAuth::AccessToken.new(consumer, user_qq.access_token, user_qq.access_secret)
        res = access_token.post("http://open.t.qq.com/api/t/comment", {:content=>self.content, :reid=>self.post.tencent_weibo_id})
        res = ActiveSupport::JSON.decode(res.body)
        self.tencent_weibo_id = res["data"]["id"] if res["msg"] == "ok"
      end
      
    rescue Exception=>err
      p err
      logger.info err
    end
  end
  
  # 查看 user 最新发送及收到的评论 wang
  #def self.find_user_posts_comments(user,params)
  #  MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_comments_count)
  #  Comment.paginate(:per_page => params[:per_page]||25,:conditions=>['(posts.user_id=? or comments.content like ?) and posts.score is null or comments.user_id = ?',user.id,"%@#{user.name}%",user.id],:joins=>"inner join posts on posts.id = comments.post_id",:select=>'comments.*',:page => params[:page]||1,:include=>[:user],:order => "comments.id desc")
  #end 
  
  ########json##########

  def refer_time
    from_time = self.created_at
    to_time = Time.new
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    include_seconds = false
    case distance_in_minutes
      when 0..1
      return "1 #{APP_CONFIG['time_label_minute']}" unless include_seconds
      case distance_in_seconds
        when 0..5   then "5#{APP_CONFIG['time_label_second']}"
        when 6..10  then "10#{APP_CONFIG['time_label_second']}"
        when 11..20 then "20#{APP_CONFIG['time_label_second']}"
        when 21..40 then "#{APP_CONFIG['time_label_half_min']}"
        when 41..59 then "1#{APP_CONFIG['time_label_minute']}"
      else             "1#{APP_CONFIG['time_label_minute']}"
      end
      when 2..45      then "#{distance_in_minutes}#{APP_CONFIG['time_label_minute']}"
      when 46..90     then "1#{APP_CONFIG['time_label_hour']}"
      when 91..1440   then "#{(distance_in_minutes.to_f / 60.0).round}#{APP_CONFIG['time_label_hour']}"
      when 1441..2880 then "#{APP_CONFIG['time_label_yes']}"
      when 2881..4320 then "#{APP_CONFIG['time_label_before']}"
    else 
      from_time.strftime("%Y-%m-%d")
    end
  end

  # ==json_attrs 输出字段
  # * id: 评论ID
  # * content: 评论内容
  # * created_at: 评论时间
  # 
  def self.json_attrs
    %w{id content created_at post_id}
  end
  
  def post_username
    self.post.user.name if self.post
  end
  
  def post_content
    self.post.content
  end
  
  # ==json_methods 输出方法
  # * user: 评论人信息,结构参考user
  # * status: 评论的微博,结构参考status
  # 
  def self.json_methods
    [:post_username, :post_content]
  end 
  
  #alias :status :post
  
  def as_json(options = {})
    options[:only] ||= Comment.json_attrs
    options[:methods] ||= Comment.json_methods
    options[:include] ||= {:user=>{:only=>User.json_attrs, :methods=>User.json_methods}, :post=>{:only=>Post.json_attrs, :methods=>[:logo_url, :logo_url_thumb120, :logo_url_thumb400], :include=>{:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}}}}
    super options
  end
end
