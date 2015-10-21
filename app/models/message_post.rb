class MessagePost < ActiveRecord::Base
  belongs_to :message_topic,:counter_cache => true
  belongs_to :user
  belongs_to :message_user, :class_name=> "User",:foreign_key => "message_user_id"
  #after_create :send_apn
  
  attr_accessor :user_name
  
  validates_presence_of :user_id
  validates_presence_of :message_user_id
  validates_length_of :content, :within => 1..500,:too_long=>APP_CONFIG['error_message_content'],:too_short=>APP_CONFIG['error_message_content']
  
  #发推送
  def send_apn()
    if self.message_topic.user_id == self.user_id
      MamashaiTools::ToolUtil.push_aps(self.message_topic.message_user_id, "收到私信：#{self.content}", {"t"=>"private_message"})
    end
  end

  def self.create_message_post(params,user)
    message_post = MessagePost.new(params[:message_post])
    if message_post.user_name.blank?
      message_post.errors.add(:user_name,APP_CONFIG['error_message_user_name']) 
      return message_post
    end
    message_user = User.find_by_name(message_post.user_name)
    unless message_user
      message_post.errors.add(:user_name,APP_CONFIG['error_message_on_user'])
      return message_post
    end
    
    user_topic = MessageTopic.find(:first,:conditions=>['user_id=? and message_user_id=?',user.id,message_user.id])
    
    if user.id != User.mms_user_id
      fans_user = FollowUser.find_one_follow_user(message_user,user)
      if user_topic.blank? and fans_user.blank?
        message_post.errors.add(:user_name,APP_CONFIG['error_message_on_fans_user'])
        return message_post
      end
    end
    
    message_post.message_user_id = message_user.id
    message_post.user_id = user.id
    message_post.save
    unless message_post.errors.blank?
      return message_post
    end
    
    ActiveRecord::Base.transaction do  
      
      user_topic = MessageTopic.create(:user_id=>user.id,:message_user_id=>message_user.id) unless user_topic
      message_user_topic = MessageTopic.find(:first,:conditions=>['user_id=? and message_user_id=?',message_user.id,user.id])
      message_user_topic = MessageTopic.create(:user_id=>message_user.id,:message_user_id=>user.id) unless message_user_topic
      
      message_post.message_topic_id = user_topic.id
      message_post.save 
      user_topic.last_message_post_id = message_post.id
      user_topic.save
      
      message_user_post = MessagePost.new(params[:message_post])
      message_user_post.user_id = user.id 
      message_user_post.message_user_id = message_user.id
      message_user_post.message_topic_id = message_user_topic.id
      message_user_post.save
      message_user_topic.last_message_post_id = message_post.id
      message_user_topic.save
      
      p message_user
      MamashaiTools::ToolUtil.add_unread_infos(:create_message_post,{:user=>message_user})
    end
    message_post.send_apn
    message_post
  end
  
  def self.create_sys_post(params,sys_topic)
    message_post = MessagePost.new(params[:message_post])
    ActiveRecord::Base.transaction do  
      message_post.user_id = User.mms_user_id
      message_post.message_user_id = User.mms_user_id
      message_post.message_topic = sys_topic
      message_post.save 
      unless message_post.errors.blank?
        return message_post
      end
      sys_topic.last_message_post_id = message_post.id
      sys_topic.created_at = Time.new                     #更新时间
      sys_topic.save
      MamashaiTools::ToolUtil.add_unread_sys_infos
    end
    message_post
  end
  
  def refer_time
    from_time = self.created_at
    to_time = Time.new
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    include_seconds = false
    
    case distance_in_minutes
      when 0..1
      return "1 #{APP_CONFIG['time_label_minute']}" unless include_seconds
      case distance_in_seconds
        when 0..5   then "5#{APP_CONFIG['time_label_second']}"
        when 6..10  then "10#{APP_CONFIG['time_label_second']}"
        when 11..20 then "20#{APP_CONFIG['time_label_second']}"
        when 21..40 then "#{APP_CONFIG['time_label_half_min']}"
        when 41..59 then "1#{APP_CONFIG['time_label_minute']}"
      else             "1#{APP_CONFIG['time_label_minute']}"
      end
      when 2..45      then "#{distance_in_minutes}#{APP_CONFIG['time_label_minute']}"
      when 46..90     then "1#{APP_CONFIG['time_label_hour']}"
      when 91..1440   then "#{(distance_in_minutes.to_f / 60.0).round}#{APP_CONFIG['time_label_hour']}"
      when 1441..2880 then "#{APP_CONFIG['time_label_yes']}"
      when 2881..4320 then "#{APP_CONFIG['time_label_before']}"
    else 
      from_time.strftime("%Y-%m-%d")
    end
  end
  
  
  ##############json########
  # ==json_attrs 输出字段
  # * id: 私信ID
  # * text: 私信内容
  # * user_id：发送人UID
  # * message_user_id: 接受人UID
  # * created_at: 发送时间
  
  def self.json_attrs
    %w{id content created_at user_id message_user_id}
  end
  
  # ==json_methods 输出方法
  # * user: 发送人信息，参考user说明
  # * message_user: 接受人信息，参考user说明 
  # 
  def self.json_methods
    %w{user message_user refer_time}
  end
  
  def as_json(options = {})
    options[:only] ||= MessagePost.json_attrs
    options[:methods] ||= MessagePost.json_methods
    super options
  end
  
end
