class EventPay < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  validates_presence_of :event_id
  
  
  
end
