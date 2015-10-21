class EventBabyPlan < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :tags
  
  
end
