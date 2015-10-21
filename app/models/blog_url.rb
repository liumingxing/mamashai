class BlogUrl < ActiveRecord::Base 
  belongs_to :user
  
  validates_presence_of :url
  validates_presence_of :user_id
  
  def self.create_blog_url(item,user)
    unless BlogUrl.find_by_url_and_user_id(item.link,user.id)
      blog_url = BlogUrl.create(:url=>item.link,:user_id=>user.id)
      Post.create(:content=>item.title,:user_id=>user.id,:blog_url_id=>blog_url.id,:created_at=>item.pubDate.to_s)
    end
  end
  
end
