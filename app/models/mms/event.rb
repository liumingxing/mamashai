class Mms::Event < ActiveRecord::Base
  set_table_name :mms_events
  has_many :mms_award_users, :class_name=>"Mms::AwardUser",:foreign_key => "mms_event_id",:dependent => :destroy,:include=>[:user],:order=>"award_date desc"
  
  STATE_TYPES = [
     [ 0 , "未开始" ],
     [ 1 , "正在进行" ],
     [ 2 , "已结束" ]
   ]
  AWARD_TYPES=[
    [ 0 , '奖项一' ],
    [ 1 , '奖项二' ],
    [ 2 , '奖项三' ]
  ]
  
  validates_presence_of :url,:name,:image_url,:begin_time,:end_time,:message => '不能为空'
#  validates_inclusion_of :state, :in => STATE_TYPES.map { |key,value| key }, :message => "状态暂不支持 %s "
  validates_format_of :image_url, :with => %r{\.(gif|jpg|png|jpeg)$}i, :message => "必须为图片格式：gif|jpg|png|jpeg"
  
  def self.all_states
    STATE_TYPES.map{|s| s.reverse }
  end
  
  def get_state
    STATE_TYPES[self.state][1]
  end
  
  def self.award_types
    AWARD_TYPES
  end
  
  def self.all_award_types
    AWARD_TYPES.map{|s| s.reverse }
  end
  
  def self.get_award_type(award_type)
    AWARD_TYPES[award_type][1]
  end
  
  def get_award_users(award_type=0)
    self.mms_award_users.find(:all,:conditions=>["award_type=?",award_type])
  end
  
end
