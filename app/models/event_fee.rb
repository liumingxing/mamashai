class EventFee < ActiveRecord::Base
  belongs_to :event
  has_many :event_fee_items,:dependent => :delete_all
  validates_presence_of :event_id
  
  def self.create_event_fee(event,user,params) 
    ActiveRecord::Base.transaction do
      event_fee = EventFee.new(params[:event_fee])
      event_fee.event_id = event.id
      event_fee.save
      params[:fee_name].each do |i,name|
        PostFeeItem.create(:name=>name,:fee1=>params[:fee1][i],:fee2=>params[:fee2][i],:event_fee_id=>event_fee.id) 
      end
      total_fee1 = 0 
      total_fee2 = 0 
      event_fee.event_fee_items.each do |fee|
        total_fee1 += fee.fee1
        total_fee2 += fee.fee2
      end  
      event_fee.total_fee1 = total_fee1
      event_fee.total_fee2 = total_fee2
      event_fee.total_fee3 = total_fee1 - total_fee2
      event_fee.save
      
    end
  end
  
end
