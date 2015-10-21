class VipUserApply < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :net_time
  validates_presence_of :topics
  validates_presence_of :to_do
  
 
  
end
