class AlbumComment < ActiveRecord::Base
  belongs_to :user
  after_create :create_comment

  def create_comment
    post = Post.find(:first, :conditions=>"`from`='album_book' and from_id = #{self.book_id}")
    if post
      comment = Comment.new
      comment.post_id = post.id
      comment.content = self.content
      comment.user_id = self.user_id
      comment.save
    end
  end
  
  def self.json_methods
    [:user]
  end 
  
  def as_json(options = {})
    options[:methods] ||= AlbumComment.json_methods
    super options
  end
end
