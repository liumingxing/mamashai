class MessageTopic < ActiveRecord::Base
  belongs_to :user
  belongs_to :message_user,:class_name=> "User",:foreign_key => "message_user_id"
  belongs_to :last_message_post,:class_name=> "MessagePost",:foreign_key => "last_message_post_id"
  has_many :message_posts
  
  validates_presence_of :user_id
  validates_presence_of :message_user_id
  
  
  def find_message_posts(params)
    conditions = ["message_posts.message_topic_id=#{self.id}"]
    conditions << params[:cond] if params[:cond]
    
    if params[:cond]
      MessagePost.all(:conditions=>conditions.join(' and '), :include=>[:message_user,:user], :order => "message_posts.id desc")
    else
      MessagePost.paginate(:per_page => params[:per_page]||25,:conditions=>conditions.join(" and "),:include=>[:message_user,:user],:page => params[:page]||1,  :order => "message_posts.id desc") 
    end
  end
  
  ################## class methods ##################
  
  def self.find_message_topics(user,params)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_messages_count)
    conditions = ["(message_topics.user_id=#{user.id} or message_topics.is_sys=1)"]
    conditions << params[:cond] if params[:cond]
    conditions << "message_posts.content not like '亲，欢迎来到妈妈晒。我们是一个记录工具，帮助%'" if user.id == 431
    MessageTopic.paginate(:per_page => params[:per_page]||25,:conditions=>conditions.join(" and "),:include=>[:message_user],:page => params[:page]||1, :joins=>"left join message_posts on message_posts.id = message_topics.last_message_post_id", :order => "message_posts.created_at desc, id desc")
  end
  
  def self.find_sys_topic
     sys_topic = MessageTopic.find(:first,:conditions=>['is_sys=?',true])
     sys_topic = MessageTopic.create(:user_id=>User.mms_user_id,:message_user_id=>User.mms_user_id,:is_sys=>true) unless sys_topic   
     sys_topic
  end
  
  def content
    last_message_post.try(:content)||"null"
  end
  
  def last_message_time
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
  
  def message_user_name
    if self.message_user
      self.message_user.name 
    else
      " "
    end
  end
  
  def message_user_logo
    if self.message_user
      self.message_user.logo.url 
    else
      " "
    end
  end
  
  def message_user_logo_thumb48
    if self.message_user
      self.message_user.logo_thumb48.url 
    else
      " "
    end
  end
  
  def message_user_logo_thumb140
    if self.message_user
      self.message_user.logo_thumb140.url 
    else
      " "
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
    %w{id created_at user_id message_user_id refer_time is_sys}
  end
  
  # ==json_methods 输出方法
  # * user: 发送人信息，参考user说明
  # * message_user: 接受人信息，参考user说明 
  # 
  def self.json_methods
    %w{content message_posts_count last_message_time message_user_name message_user_logo message_user_logo_thumb140 message_user_logo_thumb48}
  end
  
  def as_json(options = {})
    options[:only] ||= MessageTopic.json_attrs
    options[:methods] ||= MessageTopic.json_methods
    super options
  end
  
end
