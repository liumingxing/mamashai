class EventNameStick < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :kid_name,:message=>'请输入孩子真实姓名'
  validates_presence_of :mobile,:message=>'请输入手机号'
  validates_uniqueness_of :mobile,:message=>'本手机号已经申请过'
  validates_presence_of :address,:message=>'请输入寄送地址'
  validates_uniqueness_of :address,:message=>'此寄送地址已经申请过' 
  validates_presence_of :mother,:message=>'请输入真实姓名'
  validates_presence_of :gender,:message=>'请输入孩子性别'
  validates_presence_of :birthday,:message=>'请输入孩子生日'
  validates_uniqueness_of :user_id
  
  
  def self.find_by_date_and_email(date,email)
    sqls =[]
    includes = [:user]
    sqls << EventNameStick.send(:sanitize_sql,["event_name_sticks.created_at between ? and ?", date,date+1]) if date
    sqls << EventNameStick.send(:sanitize_sql,["users.email = ?", email]) if email
    
    return EventNameStick.find(:all,:conditions=>sqls.collect{|c| "(#{c})"}.join(' AND '),:include=>includes, :order=>"event_name_sticks.created_at")
    
    
#    EventNameStick.find(:all,:conditions=> ["created_at between ? and ?",some_date, some_date+1], :order=>:created_at)
  end
  
end
