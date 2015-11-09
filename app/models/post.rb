#require 'rmmseg'
#include RMMSeg
require 'elasticsearch/model'

class Post < ActiveRecord::Base
  after_create :add_command_code

  after_create :add_at_remind
  after_create :add_new_user_notify
  #before_create :check_block_public
  before_create :check_valid
  before_create :get_age_id
  before_create :get_kid_month
  #before_create :make_rmmseg
  after_create :make_score
  #after_create :create_sphinx_index

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  after_create :check_album_book
  
  belongs_to :user, :counter_cache => true, :include=>"user_kids"
  belongs_to :age, :counter_cache => true
  belongs_to :subject, :counter_cache => true
  belongs_to :category
  belongs_to :tag
  belongs_to :forward_post, :class_name=> "Post",:foreign_key => "forward_post_id",:counter_cache=>'forward_posts_count'
  belongs_to :forward_user, :class_name=> "User",:foreign_key => "forward_user_id"
  belongs_to :gift
  belongs_to :blog_url,:dependent => :destroy
  belongs_to :video_url,:dependent => :destroy
  belongs_to :event, :counter_cache => true
  belongs_to :tuan, :counter_cache => "forward_posts_count"
  has_many :comments,:dependent => :delete_all, :order=>"comments.created_at desc"
  has_many :favorite_posts,:dependent => :delete_all
  has_many :post_recommends,:dependent => :delete_all
  #has_many :post_rates,:dependent => :delete_all
  has_many :post_logos
  belongs_to :long_post,:dependent => :destroy 
  has_one :spot,:dependent => :destroy
  has_one :eproduct,:dependent => :destroy
  belongs_to :blog_category
  belongs_to :vote, :foreign_key=>"from_id"
  belongs_to :picture, :foreign_key=>"from_id"
  belongs_to :column_chapter, :foreign_key=>"from_id"
  belongs_to :article, :foreign_key=>"from_id"
  belongs_to :gou, :foreign_key=>"from_id"
  belongs_to :tao, :foreign_key=>"from_id"
  belongs_to :tao_product, :foreign_key=>"from_id"
  belongs_to :place_comment, :foreign_key=>"from_id"
  belongs_to :video, :foreign_key=>"from_id"
  belongs_to :wotao, :foreign_key=>"from_id", :class_name=>"TaobaoProduct"
  belongs_to :lamadiary, :foreign_key=>"from_id"
  has_one :post_location
  
  named_scope :not_hide, :conditions=>["posts.is_hide <> 1"], :include=>[:user]
  named_scope :not_private, :joins=>"left join blockpublics on blockpublics.user_id = posts.user_id", :conditions=>["posts.is_private <> 1 and blockpublics.user_id is null"]
  named_scope :not_hide_pure, :conditions=>["posts.is_hide <> 1"]
  named_scope :spots, :include=>[:spot],:conditions=>["posts.spot_id is not null and posts.is_hide <> 1"], :order=>"posts.created_at desc"
  named_scope :eproducts, :include=>[:eproduct],:conditions=>["posts.eproduct_id is not null and posts.is_hide <> 1"], :order=>"posts.created_at desc"
  named_scope :events, :include=>[:event],:conditions=>["posts.event_id is not null and posts.is_hide <> 1"], :order=>"posts.created_at desc"
  named_scope :asks, :conditions=>["posts.score is not null and posts.is_hide <> 1"], :order=>"posts.created_at desc"
  named_scope :info, :conditions=>["posts.tp > 0"] # 1 is robot , 2 is org , 0 is normal
  named_scope :blog, :conditions=>["posts.long_post_id is not null"] 
  named_scope :gou, :conditions=>"posts.from = 'gou' and posts.is_hide<>1 "
  named_scope :tao, :conditions=>"(posts.from = 'tao_visit' or posts.from = 'tao') and posts.is_hide<>1 "
  named_scope :na, :conditions=>"(posts.from = 'na_visit' or posts.from = 'na') and posts.is_hide<>1 "
  named_scope :all_gou, :conditions=>"(posts.from = 'gou' or posts.from = 'na' or posts.from = 'tao') and posts.is_hide<>1 "
  named_scope :not_visit, :conditions=>"(posts.`from` != 'wotao' and posts.`from` != 'tao_visit' and posts.`from` != 'na_visit' and posts.`from` != 'download' and posts.`from` != 'book_visit' or posts.`from` is null)"
  named_scope :bbrl, :conditions=>"is_hide <> 1 and posts.`from` in (#{%w(shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance).collect{|t| "'" + t + "'"}.join(',')})"
  named_scope :bbrl2, :conditions=>"is_hide <> 1 and posts.`from` in (#{%w(shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi).collect{|t| "'" + t + "'"}.join(',')})"
  named_scope :lmrb, :conditions=>"is_hide <> 1 and logo is not null and posts.`from` in (#{%w(lama_web lama_sina lama_qq lama_iphone lama_baidu).collect{|t| "'" + t + "'"}.join(',')})"
  named_scope :wotao, :conditions=>"is_hide<>1 and `from`='wotao'"
  named_scope :taotaole, :conditions=>"is_hide<>1 and `from`='taotaole'"
  named_scope :not_taotaole_fav, :conditions=>"posts.`from` != 'taotaole_fav' and posts.`from` !='taotaole' or posts.`from` is null"
  
  named_scope :user_is, lambda{|user|
    return {:conditions=>["posts.user_id = ? and posts.is_hide <> 1",user.id]} if user.is_a? User
    return {:conditions=>["posts.user_id = ? and posts.is_hide <> 1",user]} if user.is_a? Integer
  }
  
  upload_column :logo, :process => '1024x4000', :versions => {:thumb60 => "60x200", :thumb120 => "1200x240", :thumb400 => "1000x600"}, :store_dir=>proc{|post, file| "post/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }
                           
  attr_accessor :video_link,:long_content, :new_video_link

  attr_accessor :lon,:lat
  
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']

  after_create :push_aps
  def push_aps
    if self.forward_post
      MamashaiTools::ToolUtil.push_aps(self.forward_post.user_id, "#{self.user.name}转晒了您的记录：#{self.content}", {"t"=>"comment"})
    end

    names = MamashaiTools::TextUtil.scan_atme_names(self.content)
    for name in names
      user = User.find_by_name(name)
      if user
        MamashaiTools::ToolUtil.push_aps(user.id, "#{self.user.name}：#{self.content}", {"t"=>"comment"})
      end
    end

    #`curl -X POST -u "JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ" -H "Content-Type: application/json" --data '{"aps": {"alert": "#{self.user.name}刚刚转晒您的记录：#{self.content}"}, "aliases": ["#{self.forward_post.user.email}"]}' https://go.urbanairship.com/api/push/`
  end

  after_create :upload_to_aliyun

  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)
    
    begin                     
      $connection.put("upload/post/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/post/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb60.filename}", File.open(self.logo.thumb60.path), {:content_type => self.logo.thumb60.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/post/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb120.filename}", File.open(self.logo.thumb120.path), {:content_type => self.logo.thumb120.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/post/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb400.filename}", File.open(self.logo.thumb400.path), {:content_type => self.logo.thumb400.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    rescue
    end
  end
  
  ################## attributes ################
  def month
    UserKid.all(:conditions=>"user_id = #{self.user_id}").map{|kid| kid.month}.join(',')
  end
  
  def has_relation
    self.forward_posts_count > 0 || self.favorite_posts_count > 0 || self.comments_count > 0 || UserBookPage.find_by_post_id(self.id)
  end
  
  def has_tag_score
    self.tag_id and !self.forward_post_id
  end
  
  def has_reward_tag
    Tag.reward_tag_ids.include?(self.tag_id)
  end
  
  def add_at_remind
    names = MamashaiTools::TextUtil.scan_atme_names(self.content)
    for name in names
      user = User.find_by_name(name)
      if user
        AtRemind.create(:post_id => self.id, :user_id => user.id) rescue nil
      end
    end
    
    if self.forward_post
      AtRemind.create(:post_id => self.id, :user_id => self.forward_post.user.id) rescue nil
      names = MamashaiTools::TextUtil.scan_atme_names(self.forward_post.content)
      for name in names
        user = User.find_by_name(name)
        if user
          AtRemind.create(:post_id => self.id, :user_id => user.id) rescue nil
        end
      end
    end
  end

  def add_new_user_notify
    if self.user.mms_level < 3
      c = Post.count(:conditions=>"user_id = #{self.user_id}")

      if c == 1
        message = {}
        message[:message_post] = {}
        message[:message_post][:user_name] = User.find(self.user_id).name
        message[:message_post][:content] = "亲，您成功的保存了一笔精神财富，继续努力哦！"
        message_post=MessagePost.create_message_post(message, User.find(431))
      end

      if c == 2
        message = {}
        message[:message_post] = {}
        message[:message_post][:user_name] = User.find(self.user_id).name
        message[:message_post][:content] = "亲，您有两条记录了，以后翻看的时候一定思绪万千，继续努力哦！"
        message_post=MessagePost.create_message_post(message, User.find(431))

      end

      if c == 3 || c == 10
        if self.user.score > 0
          MamashaiTools::ToolUtil.push_aps(self.user_id, "您已经获得了#{self.user.score}个晒豆，积晒豆可以换礼物哦，加油！", {"t"=>"score"})
        else
          MamashaiTools::ToolUtil.push_aps(self.user_id, "您还没有晒豆，积晒豆可以换礼物哦，加油！", {"t"=>"ddh_all"})
        end
      end
    end
  end
  
  #给晒豆
  def make_score
    if !self.is_private && %w(shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance video taotaole).include?(self.from.to_s)
      #Mms::Score.trigger_event(:mobile_post, "用手机应用进行记录", 1, 1, {:cond => :by_per_day, :user => self.user})
      
      if self.logo && ScoreEvent.count(:conditions=>"event='mobile_post' and user_id = #{self.user_id} and created_day = '#{Time.new.to_date.to_s}'") <= 3
        Mms::Score.trigger_event(:mobile_post, "用手机应用进行图片记录", 1, 1, {:user => self.user})
      end
    end 

    #if self.from == "dianping"
    #  if Post.count(:conditions=>"user_id = #{self.user_id} and `from`='dianping' and from_id = #{self.from_id}") == 1
    #    Mms::Score.trigger_event(:dianping, "参与亲子城市点评", 1, 1, {:cond => :by_per_day, :user => self.user})
    #  end
    #end
    
    #判断是否参与热点话题
    #age_tag = AgeTag.find(:first, :order=>"id desc")
    now = Time.new
    age_tag = WeekTag.find(:first, :conditions=>"current = 1")
    if self.content.to_s.index("##{age_tag.short_tag_name}#") && self.content.to_s.size >= 15
      if Post.count(:conditions=>"user_id = #{self.user_id} and created_at > '#{now.ago(30.days).to_date.to_s}' and content like '%##{age_tag.short_tag_name}#%'") < 2
        Mms::Score.trigger_event(:join_hot_topic, "参加热点话题", 1, 1, {:user => self.user})
      end
    end

    #用户等级分
    if self.logo
      self.user.add_level_score(2, "图片记录")
    else
      self.user.add_level_score(1, "文字记录")
    end
  end
  
  ################## create ####################
  def self.create_post_from_action(content, user)
    post = Post.new(:content => content)
    post.user_id = user.id
    post.save
    post
  end
  
  def self.create_post(params,user)
    if params[:post].include? :long_content
      is_long_post=true
      long_content=params[:post][:long_content]
      params[:post][:content]= MamashaiTools::TextUtil.truncate_long_content(long_content,210)  
      params[:post].delete(:long_content)
    end
    
    if params[:post].include?(:is_book)
      if params[:post][:is_book]=='1'
        is_long_post=true
        long_content=ActionController::Base.helpers.simple_format(params[:post][:content])
        params[:post][:title]=ActionController::Base.helpers.truncate(params[:post][:content],20)
      end
      params[:post].delete(:is_book)
    end
    
    params[:post].delete("sina_weibo_id") if params[:post][:sina_weibo_id] == ""
    params[:post].delete("tencent_weibo_id") if params[:post][:tencent_weibo_id] == ""
    post = Post.new(params[:post])
    if params[:poi] && params[:poi][:lat]
      post.lat = params[:poi][:lat]
      post.lon = params[:poi][:lon]
    end
    post.score = 0 if params[:post] && params[:post][:score] && params[:post][:score].blank?   # will update by js
    if post.score and post.score < 0
      post.errors.add(:score,APP_CONFIG['error_post_score']) 
      return post
    end
    if post.score and post.score > user.score
      post.errors.add(:score,APP_CONFIG['error_post_score_over']) 
      return post
    end
#    ActiveRecord::Base.transaction do
      post.user = user
      unless post.video_link.blank?
        post.video_url = VideoUrl.create(:url=>post.video_link,:user_id=>user.id)
      end
      unless post.new_video_link.blank?
        post.from_id = Video.connection.insert("INSERT INTO videos (path, url, user_id, created_at, updated_at) VALUES ('video.mp4', '#{post.new_video_link}', #{user.id}, NOW(), NOW())")
        post.from = 'video'
      end
      post.content = MamashaiTools::TextUtil.gsub_dirty_words(post.content)
      post.save
      unless post.errors.empty?
        return post
      end
      if is_long_post
        l_post=LongPost.new params[:long_post]
        l_post.content = MamashaiTools::TextUtil.gsub_dirty_words(long_content)
        l_post.user_id = user.id
        l_post.save
        return l_post unless l_post.errors.empty?
        post.long_post=l_post
        post.save
      end 
      
      user.last_login_at = Time.new
      user.last_post_id = post.id
      user.save
      #tag = Tag.create_post_content_tag(post.content)
      #post.update_attributes(:tag_id=>tag.id) if tag

      MamashaiTools::ToolUtil.update_users_atme_count(post.content)
      
      # Post.add_post_tag_score(post,user)
      User.update_invite_user_score(user) 
#    end
    
    post
  end
  
  def self.create_book_upload_post(params,user)
    post = Post.new(params[:post])
    post.is_hide = true
    post.user = user
    post.save
    User.update_all(["posts_count=?",user.posts_count],["id=?",user.id])
    post
  end
  
  def self.update_book_upload_post(user_book,user)
    book_page_post_ids = user_book.user_book_pages.collect{|book_page| book_page.post_id }
    hide_posts_count = Post.count(:all,:conditions=>['id in (?) and is_hide = ?',book_page_post_ids,true])
    Post.update_all(["is_hide=?",false],["id in (?) and is_hide = ?",book_page_post_ids,true])
    User.update_all(["posts_count=?",user.posts_count+hide_posts_count],["id=?",user.id])
  end
  
  def self.add_post_tag_score(post,user)
    if post.has_tag_score
      score_action = :create_age_or_tag
    end
  end
  
  def self.delete_post_tag_score(post,user)
    if post.has_tag_score
      score_action = :delete_age_or_tag 
    end
  end
  
  def self.create_forward_post(content,user,forward_post, from=nil)
    post =nil
    content = APP_CONFIG['forward_post'] if content.blank?
    ActiveRecord::Base.transaction do
      tag = forward_post.tag
      #content = "##{tag.name}##{content}" if tag
      post = Post.create(:from=>from, :content=>content,:user_id=>user.id,:subject_id=>forward_post.subject_id,:tag_id=>forward_post.tag_id,:age_id=>forward_post.age_id,:forward_post_id=>forward_post.id,:forward_user_id=>forward_post.user_id)
      forward_post_user = forward_post.user
      MamashaiTools::ToolUtil.add_unread_infos(:create_forward_post,{:user=>forward_post_user,:post=>post})
    end
    post
  end

  def self.create_forward_hot_topic_post(content,user)
    post =nil
    content = "推荐内容不能为空" if content.blank?
    ActiveRecord::Base.transaction do
      post = Post.create(:content=>content,:user_id=>user.id)
    end
    post
  end
  
  def self.delete_post(id,user) 
    ActiveRecord::Base.transaction do
      post = Post.find(id)
      return "user can not delete the post #{id}" unless user.is_can_delete_post?(post)
      unless post.forward_post_id.blank?
        forward_post = post.forward_post
      end
      
      if post.subject_id.present?
        su = SubjectUser.find_by_user_id_and_subject_id(post.user,post.subject)
        post.subject_id = nil
        post.save
        su.set_count if su
      end
      #post.update_attributes(:is_hide=>true)
      post.is_hide = true
      post.save
      User.update_all(["posts_count=?",user.posts_count-1],["id=?",user.id])
      
      if post.from == 'album_book'
        AlbumBook.update_all "recommand=0", "id=#{post.from_id}"
      end

      #if post.logo && post.user_id == user.id
      #  Mms::Score.trigger_event(:delete_post, "删除图片记录", -2, 1, {:user => post.user})
      #end
    end
  end  
  
  ################## home find posts ####################
  
  def self.find_recommend_posts(user,params,follow_user_ids)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.tp <> 1 and (posts.tag_id <> 38 or posts.tag_id is null) "])
    sqls << Post.send(:sanitize_sql,["posts.spot_id is null "]) 
    sqls << Post.send(:sanitize_sql,["users.tp <> 5 "]) 
    tag_ids = user.favorite_tags.collect{|ft| ft.tag_id}
    sqls << Post.send(:sanitize_sql,["(posts.age_id = ? or posts.tag_id in (?) or posts.age_id is null or posts.user_id = ?)",user.age_id,tag_ids,user.id])
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_follow_users_posts(user,params,follow_user_ids,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1"]) 
    #follow_user_ids << user.id
    sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",follow_user_ids])
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null and posts.age_id=?",params[:post_age_id]]) if params[:post_age_id].present?
    sqls << params[:cond] if params[:cond]
    sqls << params[:cond1] if params[:cond1]
    sqls << "posts.`from` like '#{params[:from]}'" if params[:from] 
    total_entries = Post.count(:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '))
    
    posts = Post.not_hide.not_private.paginate(:total_entries=>total_entries,:per_page => params[:per_page] || 25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
    posts
  end
  
  def self.find_about_me_posts(user,params,category_id=nil)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_atme_count)
    sqls = [] 
    #sqls << Post.send(:sanitize_sql,["posts.is_hide <> 1 and (posts.content like ? or posts.forward_user_id = ?)","%@#{user.name}%",user.id]) 
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null"]) if params[:post_age_id].present?
    sqls << params[:cond] if params[:cond]
    sqls << "at_reminds.user_id = #{user.id}"
    
    if params[:no_page]
      Post.not_hide.find(:all, :conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '), :joins=>"left join at_reminds on posts.id = at_reminds.post_id", :order => "posts.created_at desc")
      #Post.find(:all, :conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '), :limit=>params[:count], :order => "posts.created_at desc")
    else
      Post.not_hide.paginate(:per_page => params[:per_page]||25, :joins=>"left join at_reminds on posts.id = at_reminds.post_id", :conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
    end
    
  end
  
  def self.find_my_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ?",user.id])
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null"]) if params[:post_age_id].present?
    sqls << URI.decode(params[:cond]) if params[:cond]
    sqls << URI.decode(params[:cond1]) if params[:cond1]
    sqls << "posts.`from` like '#{params[:from]}'" if params[:from] 
    sqls << "(post_kids.kid_id = #{params[:kid_id]} or post_kids.kid_id is null)" if params[:kid_id]
    if !params[:kid_id]
      if params[:t].to_s.index("my_album_fuck")        #照片书选择素材
        posts = Post.not_hide.not_visit.paginate(:total_entries => 100, :per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at")
        posts.reverse
      else
        if params[:user] != user
          sqls << Post.send(:sanitize_sql,["posts.is_private <> 1"])
        end
        Post.not_hide.not_visit.paginate(:total_entries => 100, :per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
        
      end
    else
      if params[:user] != user
        sqls << Post.send(:sanitize_sql,["posts.is_private <> 1"])
      end
      Post.not_hide.not_visit.paginate(:total_entries => 100, :per_page => params[:per_page]||25, :joins=>"left join post_kids on post_kids.post_id = posts.id", :conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
      
    end
  end
  
  def self.find_my_long_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ? and posts.long_post_id is not null",user.id])
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null"]) if params[:post_age_id].present?
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_my_mini_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ?",user.id])
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.score is not null"]) if params[:post_tp]=='ask'
    sqls << Post.send(:sanitize_sql,["posts.from = 'vote'"]) if params[:post_tp]=='vote'
    sqls << Post.send(:sanitize_sql,["(posts.from='tao' or posts.from='na' or posts.from='gou')"]) if params[:post_tp]=='gou'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null"]) if params[:post_age_id].present?
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_all_posts(params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    sqls << "posts.`from` is null or posts.`from` <> 'tao_visit' and posts.`from` <> 'na_visit'"
    sqls << "users.age_id = #{params[:user].age_id}" if params[:from] == "same_age" && params[:user].age_id  #同年龄
    sqls << "posts.user_id in (#{(params[:user].follow_user_ids<<-1).join(',')})" if params[:from] == "follow" && params[:user]
    sqls << "users.city_id = #{params[:user].city_id}" if params[:from] == "same_city" && params[:user] && params[:user].city_id
    sqls << "users.id = #{params[:user].id}" if params[:from] == "my"
    sqls << "posts.`from`='column'" if params[:post_tp] == "column"
    sqls << "posts.`from`='picture'" if params[:post_tp] == "album"
    sqls << "posts.`from`='vote'" if params[:post_tp] == "vote"
    sqls << "posts.`from`='tao'" if params[:post_tp] == "tao"
    sqls << "(posts.`from` is null or posts.`from`<>'download')" if params[:post_tp] == "all"
    sqls << "posts.score is not null" if params[:post_tp] == "ask"
    sqls << "eproduct_id is not null" if params[:post_tp] == "product"
    sqls << Post.send(:sanitize_sql,["posts.forward_post_id is null and posts.subject_id is null"]) if params[:post_tp]=='original'
    sqls << Post.send(:sanitize_sql,["posts.subject_id is not null"]) if params[:post_tp]=='groups'
    sqls << Post.send(:sanitize_sql,["posts.logo is not null"]) if params[:post_tp]=='picture'
    sqls << Post.send(:sanitize_sql,["posts.video_url_id is not null"]) if params[:post_tp]=='video'
    sqls << Post.send(:sanitize_sql,["posts.age_id is not null"]) if params[:post_age_id].present?
    joins = ''
    joins = "left join users on posts.user_id = users.id" if sqls.collect{|c| "(#{c})"}.join(' AND ').index("users")
    
    find_params = {:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '), 
      :page => params[:page]||1,:order => "posts.created_at desc" , :joins=>joins}
    find_params[:total_entries] = 1250 if !params[:from] || params[:from] == "all" || params[:from] == "same_age"        #随便逛逛最多只显示50页
    Post.paginate(find_params)
  end

  def self.find_topic_posts(params)
    topic_type = params[:topic_type]
    sql_where = []
    sql_where << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    sql_where << Post.send(:sanitize_sql,["(MATCH(posts.content_) AGAINST(? in boolean mode))", RMMSeg.segment(params[:content]).collect{|t| "+" + t}.join(' ')])
    sql_where << Post.send(:sanitize_sql,["posts.logo is not null"]) if topic_type == "img"
#    sql_where << Post.send(:sanitize_sql,["posts.user_id = #{params[:user_id]}"]) if params[:user_id]
    #暂时屏蔽age_id过滤这一行，因为话题太少，过滤了就更不好看了。
    #sql_where << Post.send(:sanitize_sql,["posts.age_id = ?", params[:age_id]]) if params[:age_id].to_i > 0

    page = params[:page] || 1
    page = 50 if page.to_i > 50
    pa = { :select=>"posts.*, (MATCH(posts.content_) AGAINST('#{RMMSeg.segment(params[:content]).collect{|t| '+' + t}.join(' ')}' in boolean mode)) as score", 
                  :conditions => sql_where.collect{|c| "(#{c})"}.join(" AND "),
                  :per_page => params[:per_page]||25,
                  :page => page,
                  :order => "score desc"
                }
    pa[:total_entries] = params[:total_entries] if params[:total_entries]
    Post.paginate(pa)
    #Post.paginate(:joins=>"left join posts b on posts.forward_post_id = b.id", :conditions => sql_where.collect{|c| "(#{c})"}.join(" AND "),:per_page => params[:per_page]||25,:page => params[:page]||1,:order => "posts.created_at desc")
  end

  def self.find_all_hot_topic_posts(user,params)
    if params[:tp] == "all"
      tag_name = AgeTag.first(:conditions=>['tp = 0'], :order=>'week_count desc').tag.name
    end
    sql_where = []
    sql_where << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    #sql_where << Post.send(:sanitize_sql,["posts.content like ?", "%#{tag_name}%"]) if params[:tp] == "all"
    sql_where << Post.send(:sanitize_sql,["posts.age_id = ? and posts.content like ?",user.age_id, "%#{params[:tag_name]}%"]) if params[:tp] == "age" && user
    sql_where << Post.send(:sanitize_sql,["posts.user_id = ?", user.id]) if params[:tp] == "join"
    sql_where << Post.send(:sanitize_sql,["posts.content like ?", "%#{params[:tag_name]}%"]) if params[:tp] == "follow"
    Post.not_visit.paginate(:conditions => sql_where.collect{|c| "(#{c})"}.join(" AND "),:per_page => params[:per_page]||25,:page => params[:page].to_i > 50 ? 1 : params[:page],:order => "posts.created_at desc")
  end

  def self.post_of_books(book,params)
    tab_type = params[:tab_type]
    tab_type = "all" if tab_type.blank?
    sql_where = []
    sql_where << Post.send(:sanitize_sql,["(posts.is_hide <> 1 and (posts.`from` = 'book' or posts.`from` = 'book_visit') and posts.from_id = #{book.id}) or (posts.content like ? and posts.is_hide <> 1) or (subject_id in(#{book.subjects.collect{|subject|subject.id}.unshift(0).join(",")}) and posts.is_hide <> 1)","%#{book.book_name}%"]) if tab_type =="all"
    sql_where << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.content like ?","%#{params[:tag_name]}%" ])  if tab_type == "xght"
    sql_where << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.subject_id = ?",params[:subject_id]]) if tab_type == "xgqz"
    Post.not_visit.paginate(:conditions => sql_where.collect{|c| "(#{c})"}.join(" AND "),:per_page => params[:per_page]||25,:page => params[:page]||1,:order => "posts.created_at desc")
  end

  def self.huodong_of_posts(user,params)
    tp = params[:tp]
    sqls = []
    sqls << ["is_hide <> 1"]
    sqls << ["`from` in ('vkid', 'lama_vmodel')"]
    sqls << ["user_id = #{user.id}"] if tp == "join"
    sqls << ["user_id in (#{user.follow_user_ids.join(",")})"] if tp == "follow"
    Post.paginate(:per_page => params[:per_page] || 25, :page => params[:page] || 1, :conditions => sqls.collect{|c| "(#{c})"}.join(" and "), :order=> "created_at desc")
  end
  
  def self.find_favorite_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and favorite_posts.user_id=?",user.id]) 
    joins_sql = "inner join favorite_posts on posts.id = favorite_posts.post_id"
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:joins=>joins_sql,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:select=>'posts.*',:order => "favorite_posts.id desc")
  end
  
  def self.find_question_posts(user,params) 
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_answers_count)
    if params[:tp].blank?
      return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>["posts.is_hide <> 1 and posts.user_id = ? and posts.score is not null",user.id],:page => params[:page]||1,:order => "posts.created_at desc")
    end 
    if params[:tp]== 'answer'
      conditions = ["posts.is_hide <> 1 and comments.user_id = ? and posts.score is not null",user.id]
      joins_sql = "inner join comments on posts.id = comments.post_id"
      return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>conditions,:joins=>joins_sql,:select=>'posts.*',:page => params[:page]||1,:order => "posts.created_at desc")
    end
    if params[:tp]== 'new'
      return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>["posts.is_hide <> 1 and posts.user_id <> ? and posts.score is not null",user.id],:page => params[:page]||1,:order => "posts.created_at desc")
    end
  end
  
  def self.find_blog_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ? and posts.blog_url_id is not null",user.id]) 
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_picture_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ? and posts.logo is not null",user.id]) 
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_video_posts(user,params,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id = ? and posts.video_url_id is not null",user.id]) 
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  def self.find_tag_posts(tag_name,params)
    sqls = [] 
    sqls << URI.decode(params[:cond]) if params[:cond]
    sqls << "match(content_) against('#{RMMSeg.segment(tag_name).collect{|t| "+#{t}"}.join(' ')}' in boolean mode)" if tag_name.present?
    sqls << URI.decode(params[:cond1]) if params[:cond1]
    Post.not_hide.not_visit.not_private.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
  ############ books ####################
  
  def self.find_index_picture_posts
    Post.find(:all,:conditions=>['posts.is_hide <> 1 and posts.logo is not null and category_id=1'],:limit=>5,:order=>'posts.created_at desc')
  end
  
  def self.find_baby_book_posts(user,params)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.user_id=?",user.id])
    if params[:search]
      search = User.new(params[:search])
      sqls << Post.send(:sanitize_sql,["posts.created_at > ?",search.created_at]) if search and search.created_at
      sqls << Post.send(:sanitize_sql,["posts.created_at < ?",search.last_login_at]) if search and search.last_login_at
    end 
    return Post.not_hide.paginate(:per_page => 10,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:include=>[:age],:order => "posts.created_at desc")
  end
  
  def self.find_book_posts(user,params,posts_order,category_id=nil)
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.logo is not null and posts.user_id=? and logo like ?",user.id,"%g"])
    if params[:search]
      search = User.new(params[:search])
      sqls << Post.send(:sanitize_sql,["posts.created_at > ?",search.created_at]) if search and search.created_at
      sqls << Post.send(:sanitize_sql,["posts.created_at < ?",search.last_login_at]) if search and search.last_login_at
    end 
    return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:include=>[:age],:order => "posts.created_at #{posts_order}")
  end
  
  def self.find_book_text_posts(tag_name,user,params)
    Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>['posts.is_hide <> 1 and posts.content like ? and posts.user_id = ?',"%#{tag_name}%",user.id],:page => params[:page]||1,:include=>[:user],:order => "posts.created_at desc")
  end
  
  
  ####################### ask ###########################
  
  def self.find_ask_posts(user,params) 
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.score is not null"]) 
    unless params[:age_id].blank?
      sqls << Post.send(:sanitize_sql,["posts.age_id = ?",params[:age_id]])
    end
    if params[:tag_id].present? and params[:tag_id]!='all'
      sqls << Post.send(:sanitize_sql,["posts.tag_id = ?",params[:tag_id]])
    end
    if params[:tp] == 'yes'
      sqls << Post.send(:sanitize_sql,["posts.best_answer_id is not null"])
    end
    if params[:tp] == 'no'
      sqls << Post.send(:sanitize_sql,["posts.best_answer_id is null"])
    end
    return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end 
  
  
  ################tuan###############
  def self.create_forward_tuan_post(params,user)
    post =Post.new(params[:post]) if params[:post]
    post.content = APP_CONFIG['forward_post'] if params[:post] and params[:post][:content].blank?
    post.user_id = user.id
    post.save
    post
  end
  
  def self.create_forward_gou_post(params,user)
    post =Post.new(params[:post]) if params[:post]
    post.content = APP_CONFIG['forward_post'] if params[:post] and params[:post][:content].blank?
    post.user_id = user.id
    post.save
    post
  end
  
  # new add
  def self.find_user_ask_posts(user,params) 
    sqls = [] << Post.send(:sanitize_sql,["posts.is_hide <> 1 and posts.score is not null"])
    sqls << Post.send(:sanitize_sql,["posts.user_id = ?",user.id]) if user.present?
    unless params[:age_id].blank?
      sqls << Post.send(:sanitize_sql,["posts.age_id = ?",params[:age_id]])
    end
    if params[:tag_id].present? and params[:tag_id]!='all'
      sqls << Post.send(:sanitize_sql,["posts.tag_id = ?",params[:tag_id]])
    end
    if params[:tp] == 'yes'
      sqls << Post.send(:sanitize_sql,["posts.best_answer_id is not null"])
    end
    if params[:tp] == 'no'
      sqls << Post.send(:sanitize_sql,["posts.best_answer_id is null"])
    end
    sqls << Post.send(:sanitize_sql,["posts.user_id in (?)",params[:follow_user_ids]]) if params[:follow_user_ids].present?
    return Post.not_hide.paginate(:per_page => params[:per_page]||25,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:page => params[:page]||1,:order => "posts.created_at desc")
  end
  
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
  ########json##########
  # ==json_attrs 输出字段
  # * id: 晒品ID
  # * created_at: 创建时间
  # * content: 微博(晒品)内容
  # * comments_count: 评论数目
  # * favorite_posts_count: 收藏数目
  # * forward_posts_count: 转晒数目
  # * subject_id: 群组ID
  # * forward_post_id: 转发的微博ID
  # 
  def self.json_attrs
    [:id, :content, :created_at, :comments_count,:favorite_posts_count, :forward_posts_count, :kid_id, :forward_post_id, :from, :from_id, :score, :tuan_id, :claps_count, :is_private]
  end
  
  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb120: 120x120缩略图地址
  # * logo_url_thumb400: 400x400缩略图地址, 实际大小为395x395
  # 
  def self.json_methods
    [:logo_url, :logo_url_thumb60, :logo_url_thumb120, :logo_url_thumb400]
  end
  
  # 图片地址
  def logo_url
    logo.try(:url)
  end
  
  # 60x60缩略图地址
  def logo_url_thumb60
    logo.try(:thumb60).try(:url)
  end

  # 120x120缩略图地址
  def logo_url_thumb120
    logo.try(:thumb120).try(:url)
  end
  
  # 400x400缩略图地址,实际大小为395x395
  def logo_url_thumb400
    logo.try(:thumb400).try(:url)
  end
  
  # 171x147缩略图地址
  def logo_url_thumb171
    logo.try(:thumb171).try(:url)
  end
  
  def latitude
    if self.post_location
      self.post_location.latitude
    else
      nil
    end
  end
  
  def longitude
    if self.post_location
      self.post_location.longitude
    else
      nil
    end
  end

  def location_logo
    if self.post_location
      self.post_location.logo
    else
      nil
    end
  end

  def video_path
    return self.video.url if self.from == "video" && self.video && self.video.url
    return "http://www.mamashai.com" + self.video.path.try(:url) if self.from == "video" && self.video
    return nil
  end

  attr_accessor :no_user_json
  
  def province_id
    self.try(:user).try(:province_id)
  end

  def city_id
    self.try(:user).try(:city_id)
  end
  #forward_post也要包含在里面，only, methods不能递归使用
  def as_json(options = {})
    if options[:stay]
      only = Post.attribute_names
      only.delete("logo")
      return super(:only=>only, :methods=>%w(province_id city_id))
    end

    if %w(na tao tao_visit na_visit).include?(self.from)
      self.logo = self.gou.logo if self.gou
    end
#    options[:only] = (options[:only] || []) + User.json_attrs

    options[:only] = (options[:only] || []) + Post.json_attrs if !options[:only]
    options[:methods] = (options[:methods]||[]) + Post.json_methods if !options[:methods]
    
    if self.video_path
      options[:methods] << "video_path"
    else
      options[:methods].delete("video_path")
    end

    if self.forward_post && self.forward_post.is_hide
      o = self.forward_post
      self.forward_post = Post.new(:content=>"记录已被删除", :user_id=>o.user_id, :created_at=>o.created_at)
    end
    
    if !self.no_user_json
      options[:include] = {:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}, :forward_post=>{:only=>[:id, :user_id, :from, :content], :include=>{:post_logos=>{:only=>[:id], :methods=>PostLogo.json_methods}, :tao_product=>{:only=>%w(id name price short_url)}}, :methods=>[:logo_url, :logo_url_thumb60, :logo_url_thumb120, :logo_url_thumb400]}, :forward_user=>{:only=>[:id, :name]}} if !options[:include]
    else
      options[:include] = {:forward_post=>{:only=>[:id, :user_id, :from, :content], :include=>{:post_logos=>{:only=>[:id], :methods=>PostLogo.json_methods}, :tao_product=>{:only=>%w(id name price short_url)}}, :methods=>[:logo_url, :logo_url_thumb60, :logo_url_thumb120, :logo_url_thumb400]}, :forward_user=>{:only=>[:id, :name]}} if !options[:include]
    end

    if self.logo && self.post_logos && self.post_logos.length > 1
      options[:include] = {} if !options[:include]
      options[:include].merge!({:post_logos=>{:only=>%w(id), :methods=>PostLogo.json_methods}})
    end

    if self.from == "taotaole"
      options[:include] = {} if !options[:include]
      options[:include].merge!({:tao_product=>{:only=>%w(id name price short_url)}})
    end

    if self.from == "dianping"
      options[:include] = {} if !options[:include]
      options[:include].merge!({:place_comment=>{:only=>PlaceComment.json_attrs, :include=>{:place=>{:only => Place.json_attrs, :methods=>Place.json_methods}}}})
    end
    super options
  end

  def add_command_code
    code = CommandCode.new
    code.code = "Post.find(#{self.id}).make_rsync"
    code.after = Time.now.since(10.seconds)
    code.status = 'wait'
    code.save
  end

  #同步新浪微博、腾讯微博
  def make_rsync
    save_to_sina
    save_to_qq
    self.save

    if self.logo && (self.sina_weibo_id.to_i > 1 || self.tencent_weibo_id.to_i > 1)
      if ScoreEvent.count(:conditions=>"event = 'share_post' and user_id = #{self.user_id} and created_day = '#{Time.new.to_date.to_s}'") == 0
        Mms::Score.trigger_event(:share_post, "图片记录分享到了新浪微博或腾讯微博", 1, 1, {:user => self.user})
      end
    end
  end
  
  #########sina 微博同步 #####
  def save_to_sina
    if self.sina_weibo_id.to_i == -1
      self.sina_weibo_id = nil
      return;
    end

    return if self.sina_weibo_id
    return if %w(na_visit tao_visit).include?(self.from)
    begin
      from = self.from.to_s
      from = "baby_calendar" if %w(calendar shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance album_book taotaole huodong).include?(self.from)
      token = Weibotoken.get('sina', from)
      return if !token
      
      user_weibo = UserWeibo.find(:first, :conditions=>"user_id = #{self.user_id} and tp = #{token.tp}", :order=>"id desc")
      return if !user_weibo
      return if !user_weibo.to_sina
      
      status = self.content.gsub('@', '%40')
      status += " http://www.mamashai.com/tao/index" if self.from == "wotao"
      status += " http://www.mamashai.com/articles/article/#{self.from_id}" if self.from == "article"
      status += " http://www.mamashai.com/pub/columns/#{self.user_id}?chapter_id=#{self.from_id}" if self.from == "column"
      
      location_str = ''
      if self.lat && self.lon
        location_str += "&long=#{self.lon}&lat=#{self.lat}"
      end

      if self.forward_post_id && self.forward_post && self.forward_post.sina_weibo_id   #转发
          text = `curl -d 'status=#{status}' -d 'id=#{self.forward_post.sina_weibo_id}' 'https://api.weibo.com/2/statuses/repost.json?source=#{token.token}&access_token=#{user_weibo.access_token}#{location_str}'`
      else                                                                              #发原文
          if self.logo      #带图片
            text = `curl -F 'status=#{status}' -F 'pic=@#{self.logo.path}' 'https://api.weibo.com/2/statuses/upload.json?source=#{token.token}&access_token=#{user_weibo.access_token}#{location_str}'`
            p "curl -F 'status=#{status}' -F 'pic=@#{self.logo.path}' 'https://api.weibo.com/2/statuses/upload.json?source=#{token.token}&access_token=#{user_weibo.access_token}#{location_str}'"
          else              #不带图片
            if self.forward_post_id
              status = status + " http://www.mamashai.com/post/#{self.forward_post_id}" if !self.content.index("/post/#{self.forward_post_id}")
            end
            p "curl -d 'status=#{status}' 'https://api.weibo.com/2/statuses/update.json?source=#{token.token}&access_token=#{user_weibo.access_token}#{location_str}'"
            text = `curl -d 'status=#{status}' 'https://api.weibo.com/2/statuses/update.json?source=#{token.token}&access_token=#{user_weibo.access_token}#{location_str}'`
          end
      end
      
      json = ActiveSupport::JSON.decode(text)
      if json['error'] == "expired_token"
        count = MessagePost.count(:conditions=>"message_user_id = #{self.user.id} and user_id = 431 and created_at > '#{Time.new.ago(7).to_s(:db)}' and content = '亲，我们检测到您的记录同步微博失败，是因为您的的微博绑定已过期，需要重新绑定才可正常同步新浪。您只需要退出登录，然后用新浪微博重新登录即可。'")
        if count == 0
          message = {}
          message[:message_post] = {}
          message[:message_post][:user_name] = self.user.name
          message[:message_post][:content] = "亲，我们检测到您的记录同步微博失败，是因为您的的微博绑定已过期，需要重新绑定才可正常同步新浪。您只需要退出登录，然后用新浪微博重新登录即可。"
          message_post=MessagePost.create_message_post(message, User.find(431))
        end
      end
      self.sina_weibo_id = json["id"]
    rescue => e
      logger.error e.inspect
    end
  end
  
  def save_to_qzone
    return if self.qzone_id
    return if %w(na_visit tao_visit).include?(self.from)
    
    begin
      token = Weibotoken.get('qzone', 'baby_calendar')
      return if !token

      user_qzone = UserQzone.find(:first, :conditions=>["user_id = ? and tp = ?", self.user_id, token.tp])
      return if !user_qzone
      
      title = "来自宝宝日历的记录"
      url = "http://www.mamashai.com/mobile/post/#{self.id}"
      site = "宝宝日历"
      fromurl = "http://www.mamashai.com/bbrl/mobile"

      the_url = "https://graph.qq.com/share/add_share?access_token=#{user_qzone.access_token}&oauth_consumer_key=#{token.token}&openid=#{user_qzone.openid}&title=#{title}&url=#{url}&summary=#{URI.escape(self.content)}&nswb=1"
      if self.logo
        the_url += "&images=http://www.mamashai.com/upload/post/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self['logo']}"
      end
      p the_url
      text = `curl '#{the_url}'`
      json = JSON.parse(text)
      self.qzone_id = json["share_id"]
      self.save
    rescue
    end

    return true;
  end

  #########腾讯微博同步 #####
  def save_to_qq
    return if self.tencent_weibo_id
    return if %w(na_visit tao_visit).include?(self.from)
    begin
      from = self.from.to_s
      from = "baby_calendar" if %w(calendar shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi jiance album_book taotaole video jiance).include?(self.from)
      token = Weibotoken.get('qq', from)
      return if !token
      
      user_qq = UserQq.find(:first, :conditions=>"user_id = #{self.user_id} and tp = #{token.tp}")
      return if !user_qq
      return if !user_qq.to_qq
      
      consumer = OAuth::Consumer.new(token.token, token.secret, CONSUMER_OPTIONS)
      access_token = OAuth::AccessToken.new(consumer, user_qq.access_token, user_qq.access_secret)
    
      new_content = self.content
      pic = logo
      if %w(na tao gou download).include?(self.from)
        pic = self.gou.logo
        new_content = new_content + " http://www.mamashai.com/gou/show/#{self.gou.id}"
      end
      
      if self.from == 'column' && self.from_id
        new_content = new_content + " http://www.mamashai.com/pub/columns/#{self.user_id}?chapter_id=#{self.from_id}"  
      end

      if self.from == "article"
        new_content = new_content + "http://www.mamashai.com/articles/article/#{self.from_id}"
      end
      
      if self.from == "wotao"
        new_content += " http://www.mamashai.com/tao/show/#{self.from_id}" if self.from == "wotao"
      end
      
      if self.forward_post_id
        if self.forward_post.from == 'column'
          new_content = new_content + " http://www.mamashai.com/pub/column_view/#{self.forward_post.user_id}?chapter_id=#{self.forward_post.from_id}" if !self.content.index("/column_view")
        else
          new_content = new_content + " http://www.mamashai.com/post/#{self.forward_post_id}" if !self.content.index("/post/#{self.forward_post_id}")
        end
      end
      
      new_content = new_content.gsub("]", "").gsub("[", "/")

      if self.forward_post_id && self.forward_post && self.forward_post.tencent_weibo_id    #转发
        text = `curl -F 'format=json' -F 'reid=#{self.forward_post.tencent_weibo_id}' -F 'content=#{new_content}' -F 'clientip=115.29.44.231' -F 'oauth_consumer_key=#{token.token}' -F 'access_token=#{user_qq.access_token}' -F 'openid=#{user_qq.openid}' -F 'oauth_version=2.a' -F 'scope=all' https://open.t.qq.com/api/t/re_add`
      else
        if pic
          text = `curl -F 'format=json' -F 'content=#{new_content}' -F 'pic=@#{self.logo.path}' -F 'clientip=115.29.44.231' -F 'oauth_consumer_key=#{token.token}' -F 'access_token=#{user_qq.access_token}' -F 'openid=#{user_qq.openid}' -F 'oauth_version=2.a' -F 'scope=all' https://open.t.qq.com/api/t/add_pic`
        else
          p "curl -F 'format=json' -F 'content=#{new_content}' -F 'clientip=115.29.44.231' -F 'oauth_consumer_key=#{token.token}' -F 'access_token=#{user_qq.access_token}' -F 'openid=#{user_qq.openid}' -F 'oauth_version=2.a' -F 'scope=all' https://open.t.qq.com/api/t/add"
          text = `curl -F 'format=json' -F 'content=#{new_content}' -F 'clientip=115.29.44.231' -F 'oauth_consumer_key=#{token.token}' -F 'access_token=#{user_qq.access_token}' -F 'openid=#{user_qq.openid}' -F 'oauth_version=2.a' -F 'scope=all' https://open.t.qq.com/api/t/add`
        end
      end
      res = ActiveSupport::JSON.decode(text)
      self.tencent_weibo_id = res['data']['id'] if res['data']
    rescue => e
      logger.error e.inspect
    end
  end
  
  def self.last_sina_weibo(user)
      Post.not_hide.first(:conditions=>["posts.sina_weibo_id is not null and posts.user_id =?", user.id], :order=>"created_at desc")
  end

  #判断是否属于私有黑名单中，是的话自动列为私有
  def check_block_public
    if Blockpublic.find_by_user_id(self.user_id)
      self.is_private = true
    end
  end
  
  def check_valid
    if self.created_at && self.created_at > Time.new.since(60*10)    #比较时间戳
      self.created_at = Time.new
    end
    
    last = Post.find(:first, :conditions=>"user_id = #{self.user_id}", :order=>"id desc")
    if last && Time.new - last.created_at < 10
      self.errors.add(:content, %w(您已经盯着屏幕太久了，闭目养神几分钟，可以让您的双眼更明亮 抱歉，您的操作过于频繁，一休哥提醒您：“休息，休息一下吧！” 一直对着电脑对眼睛不好哦，站到窗边远眺十分钟，休息一下吧！ 妈妈晒强制休息精灵温馨提示，离开电脑，站起来扭扭脖子和肩膀吧！)[rand(4)]) and return false
    end
    
    if last && last.content == self.content && last && Time.new - last.created_at < 180 
      self.errors.add(:content, "请不要发重复内容") and return false
    end

    if self.from == "taotaole" && self.content.include?('收藏')
      self.from = 'taotaole_fav'
    end

    age_tag = WeekTag.find(:first, :conditions=>"current = 1")
    if self.content.to_s.index("##{age_tag.short_tag_name}#") && self.content.to_s.size < 15
      self.errors.add(:content, "参与热点话题却长度不足15个字")
      return false;
    end
  end
  
  def get_age_id
    if forward_post
      self.age_id = self.forward_post.age_id
    else
      self.age_id = self.user.age_id
    end
  end

  def get_kid_month
    return if !self.user

    if self.kid_id
      kid = UserKid.find_by_id(self.kid_id)
      self.kid_month = kid.try(:month)
    else
      kid = self.user.first_kid
      self.kid_month = kid.try(:month)
    end
  end

  def get_month
    return nil if !self.user

    if self.kid_id
      kid = UserKid.find_by_id(self.kid_id)
      return kid.try(:month)
    else
      kid = self.user.first_kid
      return kid.try(:month)
    end
  end
  
  def make_rmmseg
    self.content_ = (self.content.scan(/#\p{Word}+#/) + RMMSeg::segment(self.content)).join(' ')
  end
  
  def from_calendar?
    %w(calendar shanguang fayu yingyang zaojiao caiyi biaoqing bbyulu shijian wenzi).include?(self.from)
  end

  def check_album_book
    if self.from == 'album_book' && self.from_id
      post = Post.find(:first, :conditions=>"`from`='album_book' and from_id = #{self.from_id} and id <> #{self.id}")
      #today_count = Post.count(:conditions=>"`from`='album_book' and user_id = #{self.user_id} and created_at > '#{self.created_at.at_beginning_of_day.to_s(:db)}' and created_at < '#{self.created_at.tomorrow.at_beginning_of_day.to_s(:db)}'")
      if !post
        book = AlbumBook.find(self.from_id)
        AlbumBook.update_all "recommand = 1", "id = #{self.from_id}"
        #book.recommand = true
        #book.save
      end
    end
  end

  def as_indexed_json(options={})
    options[:stay] = true;
    as_json(options)
  end
  
end
