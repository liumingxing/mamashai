class Mms::AwardUser < ActiveRecord::Base
  set_table_name :mms_award_users
  
  belongs_to :mms_event,:class_name=>"Mms::Event"
  belongs_to :user, :class_name=>"::User"
  
  validates_inclusion_of :award_type, :in => Mms::Event.award_types.map { |key,value| key }, :message => "状态暂只支持奖项一、二、三"
  validates_presence_of :user,:mms_event,:message => '不能为空'
  
  def award_type_name
    Mms::Event.award_types[self.award_type][1]
  end
end
