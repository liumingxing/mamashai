class UserLink < ActiveRecord::Base 
  belongs_to :user
  belongs_to :sys_link
  belongs_to :link_category
  
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :user_id
  
  def self.find_category_user_links(user,link_category)
    UserLink.find(:all,:conditions=>['user_id=? and link_category_id=?',user.id,link_category.id],:order=>'id desc')
  end
   
end
