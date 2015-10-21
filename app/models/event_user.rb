class EventUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :event, :counter_cache => true
  
  validates_presence_of :user_id
  validates_presence_of :event_id
  validates_presence_of :email,:message=>APP_CONFIG['error_event_user_email']
  validates_presence_of :join_num,:message=>APP_CONFIG['error_event_user_join_num']
  validates_numericality_of :join_num,:only_integer => true, :greater_than => 0, :message=>APP_CONFIG['error_event_user_join_num_format']
  
  #tp 0:signup 1:approve -1:refuse  -2:quit
  
  def self.create_event_user(params,event,user)
    event_user = EventUser.new(params[:event_user])
    if EventUser.find(:first,:conditions=>['user_id=? and event_id=? and tp <> -2',user.id,event.id])
      event_user.errors.add(:join_num,APP_CONFIG['error_event_user_signuped'])
      return event_user
    end
    
    event_user.event_id = event.id
    event_user.user_id = user.id
    event_user.save
    unless event_user.errors.empty?
      return event_user
    end
    event.event_users_sum += event_user.join_num
    event.save
    event_user
  end
  
end
