class EventPicture < ActiveRecord::Base
  belongs_to :event, :counter_cache => true
  
  upload_column :logo,:process => '1024x1024', :versions => {:thumb120 => "120x120", :thumb400 => "395x395" }
  validates_presence_of :logo
  
  def self.create_event_picture(params,event,user)
    EventPicture.create(:logo=>params[:Filedata],:event_id=>event.id,:user_id=>user.id)
  end
  
end
