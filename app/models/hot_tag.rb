class HotTag < ActiveRecord::Base 
  validates_presence_of :name
  belongs_to :tag
   
end
