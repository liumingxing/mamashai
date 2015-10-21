class LinkTag < ActiveRecord::Base 
  belongs_to :link_category
  has_many :sys_links,:order=>'order_num asc'
  
  validates_presence_of :name
  
   
end
