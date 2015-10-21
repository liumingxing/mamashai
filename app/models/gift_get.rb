class GiftGet < ActiveRecord::Base
  belongs_to :user
  belongs_to :gift,:counter_cache => true
  belongs_to :send_user, :class_name=> "User",:foreign_key => "send_user_id"
  after_create :push_aps

  after_create :make_comment_remind
  
  attr_accessor :user_name
  
  validates_presence_of :user_id
  validates_presence_of :send_user_id, :message=>APP_CONFIG['error_message_on_user']
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  

  def make_comment_remind
    CommentAtRemind.create(:tp=>"gift", :comment_id=>self.id, :user_id=>self.send_user_id, :author_id=>self.user_id, :created_at=>self.created_at)
  end

  def push_aps
    MamashaiTools::ToolUtil.push_aps(self.send_user_id, self.content, {"t"=>"comment"})
  end
  
  def self.find_user_gift_gets(user,params)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_gifts_count)
    conditions = []
    conditions << "send_user_id = #{user.id}"
    conditions << "is_get_hide = 0"
    conditions << params[:cond] if params[:cond]
    GiftGet.paginate(:per_page => 25,:conditions=>conditions.join(' and '),:include=>[:gift],:page => params[:page],:order => "gift_gets.id desc") 
  end
  
  def self.find_user_space_gift_gets(user,params)
    GiftGet.paginate(:per_page => 25,:conditions=>['send_user_id = ? and is_get_hide = ? and is_private = ?',user.id,false,false],:include=>[:gift],:page => params[:page],:order => "gift_gets.id desc") 
  end
  
  def self.find_user_gift_sents(user,params)
    GiftGet.paginate(:per_page => 25,:conditions=>['user_id = ? and is_send_hide = ?',user.id,false],:include=>[:gift],:page => params[:page],:order => "gift_gets.id desc") 
  end
  
  def self.create_user_gift_gets(user,params)
    gift_get = GiftGet.new(params[:gift_get])
    ActiveRecord::Base.transaction do
      if gift_get.user_name.blank?
        gift_get.errors.add(:user_name,APP_CONFIG['error_message_user_name']) 
        return gift_get
      end
      send_users = []
      gift_get.user_name.split(',').each do |user_name|
        send_user = User.find_by_name(user_name)
        send_users << send_user if send_user
      end
      if send_users.blank?
        gift_get.errors.add(:user_name,APP_CONFIG['error_message_on_user'])
        return gift_get
      end
      
      gift = Gift.find(gift_get.gift_id)
      
      gift_score = 0
      send_users.each do |send_user|
        if send_user.id != user.id
          new_gift_get = GiftGet.new(params[:gift_get])
          new_gift_get.send_user_id = send_user.id
          new_gift_get.user_id = user.id
          new_gift_get.is_no_name = !params[:is_no_name].blank?
          new_gift_get.is_private = !params[:is_private].blank?
          new_gift_get.save 
          new_gift_get.errors
          unless new_gift_get.errors.blank?
            return new_gift_get
          end
          MamashaiTools::ToolUtil.add_unread_infos(:create_gift_get,{:user=>send_user})
          gift_score += gift.score
        end
      end
      
      unless params[:is_new_post].blank?
        content = APP_CONFIG['send_gift_to_users']+send_users.collect{|send_user| "@#{send_user.name}" }.join(',')
        post = Post.create(:content=>content,:user_id=>user.id, :from=>'gift', :from_id=>gift.id)
        MamashaiTools::ToolUtil.update_users_atme_count(post.content)
      end
    end
    gift_get
  end
  
  def self.json_attrs
    %w(id content created_at)
  end
  
  def self.json_methods
    []
  end
  
  def as_json(options = {})
    options[:only] ||= GiftGet.json_attrs
    options[:methods] ||= GiftGet.json_methods
    
    options[:include] = {:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}, :gift => {:only=>Gift.json_attrs, :methods=>Gift.json_methods}}
    super options
  end
  
end
