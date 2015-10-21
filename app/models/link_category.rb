class LinkCategory < ActiveRecord::Base 
  
  has_many :sys_links
  has_many :user_links
  has_many :link_tags,:order=>'order_num asc'
  
  
  validates_presence_of :name
  
   
end
