class EventFeeItem < ActiveRecord::Base
  belongs_to :event_fee
  
  validates_presence_of :event_fee_id
  validates_presence_of :name
  
  
end
