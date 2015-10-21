class AnglePost < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  belongs_to :age
  has_many :angle_comments,:dependent => :delete_all
  
  upload_column :logo,:process => '1024x1024', :versions => {:thumb120 => "120x120", :thumb400 => "395x395" }
  
  
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  
  
  ################## create ####################
  
  def self.create_angle_post(params,user)
    post = AnglePost.new(params[:post])
    ActiveRecord::Base.transaction do
      post.user = user
      post.content = MamashaiTools::TextUtil.gsub_dirty_words(post.content)
      post.save
      tag = Tag.create_post_content_tag(post.content)
      post.update_attributes(:tag_id=>tag.id) if tag
      unless post.errors.empty?
        return post
      end
    end
    post
  end
  
  def self.delete_angle_post(id,user)
    ActiveRecord::Base.transaction do
      post = AnglePost.find_by_id_and_user_id(id,user.id)
      return unless post 
      post.destroy
    end
  end  
  
  
  
end
