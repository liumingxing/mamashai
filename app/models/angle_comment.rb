class AngleComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :angle_post, :counter_cache => true
  
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  
  def self.create_angle_comment(params,user,post)
    comment = AngleComment.new(params[:comment])
    ActiveRecord::Base.transaction do 
      comment.user = user
      comment.angle_post_id = post.id
      comment.save
      return comment unless comment.errors.empty? 
    end
    comment
  end
  
  def self.delete_angle_comment(comment_id,user)
    post = nil
    ActiveRecord::Base.transaction do 
      comment = AngleComment.find_by_id_and_user_id(comment_id,user.id)
      if comment
        post = comment.angle_post
        comment.destroy
      end
    end
    post
  end
  
end
