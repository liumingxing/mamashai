class UserBlog < ActiveRecord::Base 
  belongs_to :user
  
  validates_presence_of :blog_tp
  validates_presence_of :blog_name
  validates_presence_of :user_id
  
  
  
  
  def self.update_user_blogs(params,user)
    blog_tps = MamashaiTools::HttpUtil.get_blog_tps
    user_blogs = user.user_blogs
    blog_tps.each do |blog_tp|
      unless params[blog_tp.to_sym].blank?
        user_blog = user_blogs.detect{|blog| blog.blog_tp == blog_tp }
        if user_blog
          user_blog.update_attributes(:blog_name=>params[blog_tp.to_sym])
        else
          user_blog = UserBlog.create(:blog_tp=>blog_tp,:blog_name=>params[blog_tp.to_sym],:user_id=>user.id)
        end
      end
    end
    user_blogs.each do |user_blog|
      user_blog.destroy unless blog_tps.include?(user_blog.blog_tp)
    end
  end
  
  def self.update_user_blog_posts(user_blog,user)
    if user_blog.blog_tp == "weibo"
      #Post.create(:content=>item.title,:user_id=>user.id,:blog_url_id=>blog_url.id,:created_at=>item.pubDate.to_s)
    else
      rss_url = MamashaiTools::HttpUtil.get_common_rss_url(user_blog.blog_tp,user_blog.blog_name)
      return unless rss_url
      blog_items = MamashaiTools::HttpUtil.get_blog_items(rss_url)
      return if blog_items.blank?
      ActiveRecord::Base.transaction do
        blog_items.reverse.each do |item| 
          BlogUrl.create_blog_url(item,user) 
        end
      end
    end
  end
  
end
