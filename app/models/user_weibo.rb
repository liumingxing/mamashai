require 'open-uri'
require 'score'
class UserWeibo < ActiveRecord::Base
  belongs_to :user
  #validates_presence_of :access_id, :tp, :message=>"不能为空"
  #validates_uniqueness_of :access_id,:message=>"外部微博id不能重复"

  named_scope :sina,:conditions=>"user_weibos.tp=1"
  validates_uniqueness_of :access_token  
  
  # 如果用户从未在妈妈晒同步过sina微博，则将用户最新的1篇微博同步到妈妈晒
  # 如果同步过sina微博，则将接着上次同步结果继续同步到最新的sina微博
  def update_user_weibo_posts
    user_sina_weibo = Post.last_sina_weibo(user)
    attrs ={}
    if user_sina_weibo.present?
        attrs[:since_id] = user_sina_weibo.sina_weibo_id
        attrs[:count] = 200
    else
        attrs[:count] = 1
    end
    oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
    oauth.authorize_from_access(access_token, access_secret)
    posts = Weibo::Base.new(oauth).user_timeline(attrs)
    
    return if posts.blank?
    
    posts.each do |post|
        begin
            uri = post.original_pic
            params = {:post=>{:content=>post.text, :sina_weibo_id=>post.id, :created_at=>post.created_at}}
            if uri.present?
                pic = open(uri)
                pic.original_filename = uri.split('/').last
                params[:post][:logo] = pic
            end
            Post.create_post(params,user)
        rescue => e
            logger.error e.inspect
        end
    end
    
  end

end
