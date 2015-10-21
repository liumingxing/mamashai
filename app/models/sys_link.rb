class SysLink < ActiveRecord::Base 
  
  belongs_to :link_category
  belongs_to :link_tag
  
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :link_category_id
  
   
end
