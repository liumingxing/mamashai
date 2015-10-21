class FollowUser < ActiveRecord::Base
  belongs_to :user,:counter_cache=>true
  belongs_to :follow_user, :class_name=> "User",:foreign_key => "follow_user_id",:counter_cache => 'fans_users_count'

  # yj add code begin

  belongs_to :follows_group, :counter_cache=>:users_count
  belongs_to :fans_group, :counter_cache=>:users_count

  # yj add code end
  
  validates_presence_of :user_id
  validates_presence_of :follow_user_id
  
  #after_create :make_score
  after_create :push_aps
  
  #################### create ####################
  def push_aps
    if self.user.created_at.to_i + 60*5 < Time.new.to_i
      MamashaiTools::ToolUtil.push_aps(self.follow_user_id, "#{self.user.name}关注了您", {"t"=>"comment"})
    end
    #`curl -X POST -u "JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ" -H "Content-Type: application/json" --data '{"aps": {"alert": "#{self.user.name}刚刚对您的记录进行了评论：#{self.content}"}, "aliases": ["#{self.post.user.email}"]}' https://go.urbanairship.com/api/push/`  
  end

  def make_score
    if self.user.created_at.to_i + 60 < Time.new.to_i
      Mms::Score.trigger_event(:mobile_add_follows, "关注", 0, 0, {:user => self.user})
        
      if ScoreEvent.count(:conditions=>"user_id = #{self.user_id} and event = 'mobile_add_follows' and created_at > '#{Date.today.to_s(:db)}'") == 5
        Mms::Score.trigger_event(:add_follows, "一天加5个关注好友", 1, 1, {:cond => :by_per_day, :user => self.user})
      end
    end

    self.follow_user.add_level_score(1, "被关注")
  end
  
  def self.create_follow_user(to_follow_user,user)
    return 'overload' if user.follow_users_count >= 2000
    return if user.id == to_follow_user.id
    return if FollowUser.find_by_user_id_and_follow_user_id(user.id,to_follow_user.id)
    
    ActiveRecord::Base.transaction do
      follow_user = FollowUser.new(:user_id=>user.id,:follow_user_id=>to_follow_user.id)
      fansed_user = FollowUser.find_by_user_id_and_follow_user_id(to_follow_user.id,user.id)
      if fansed_user
        fansed_user.update_attributes(:is_fans=>true) 
        follow_user.is_fans = true
      end
      follow_user.save
      MamashaiTools::ToolUtil.add_unread_infos(:create_follow_user,{:user=>to_follow_user})
    end
  end
  
  def self.delete_follow_user(user,to_follow_user)
    ActiveRecord::Base.transaction do
      follow_user = FollowUser.find_by_user_id_and_follow_user_id(user.id,to_follow_user.id)
      if follow_user
        follow_user.destroy 
        fansed_user = FollowUser.find_by_user_id_and_follow_user_id(to_follow_user.id,user.id)
        if fansed_user
          fansed_user.update_attributes(:is_fans=>false) 
        end
      end
    end
  end
  
  def self.find_one_follow_user(me,guest)
    FollowUser.find(:first,:conditions=>['user_id=? and follow_user_id=?',me.id,guest.id])
  end
  
  def self.check_follow(source_user, target_user)
    source_target = find_one_follow_user(source_user, target_user)
    target_source = find_one_follow_user(target_user, source_user)
    {
      :source=>{
        :id => source_user.id,
        :name => source_user.name,
        :following => source_target.present?,
        :followed_by => target_source.present?
      },
      :target=>{
        :id => target_user.id,
        :name => target_user.name,
        :following => target_source.present?,
        :followed_by => source_target.present?
      }
    }
  end
  
end
