class SubjectUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject, :counter_cache => true
  
  def set_count
    self.update_attributes(:subject_posts_count=>Post.count(:all, :conditions=>["user_id=? and subject_id = ?",self.user_id,self.subject_id]),
                             :week_subject_posts_count=>Post.count(:all, :conditions=>["user_id=? and subject_id = ? and created_at between ? and ?",self.user_id,self.subject_id,Date.today-6,Date.today+1]))
  end
  
  def self.can_manage(user, subject)
    return SubjectUser.count(:conditions=>["user_id=? and subject_id=?",user.id,subject.id]) > 0 if (user and subject)
    return false 
  end
  
end
