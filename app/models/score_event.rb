class ScoreEvent < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :score
  validates_presence_of :event
  validates_presence_of :user_id

  before_create :get_created_day

  after_create :push_notification

  def get_created_day
    self.created_day = Date.today
  end

  def self.user_score_events(user,params)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_invited_count)
    ScoreEvent.paginate(:per_page => 25,:conditions=>['user_id=?',user.id],:page => params[:page],:order => "id desc")
  end
  
  def self.old_score_events(user,params)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_invited_count)
    ScoreEvent.paginate(:per_page => 25,:page => params[:page],:conditions=>["user_id = ?",user.id],:order=>"id desc",:from=>"score_events_2010_08_20")
  end
  
  def push_notification
    if self.score > 0
      MamashaiTools::ToolUtil.push_aps(self.user_id, "#{event_description}，获得#{self.score}个晒豆。", {"t"=>"score"})
    elsif self.score < 0
      MamashaiTools::ToolUtil.push_aps(self.user_id, "#{event_description}，扣除#{self.score.abs}个晒豆。", {"t"=>"score"})
    end
  end
end
