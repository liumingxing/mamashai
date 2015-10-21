class ArticleComment < ActiveRecord::Base
  belongs_to :article, :counter_cache => true
  belongs_to :user
  
  validates_length_of :content, :within => 1..210,:too_long=>APP_CONFIG['error_post_content_length'],:too_short=>APP_CONFIG['error_post_content_length']
  
  def self.create_article_comment(params, user, article)
    comment = ArticleComment.new(params[:comment])
    ActiveRecord::Base.transaction do 
      comment.user = user
      comment.article_id = article.id
      comment.save
      return comment unless comment.errors.empty?
      if params[:is_copy_post].to_s == "1" || params[:is_copy_post].to_s == "true"
        params[:post]={:content=>"#{comment.content} http://mamashai.com/article/#{article.id}"} if article.article_category.tp == 0
        params[:post]={:content=>"#{comment.content} http://mamashai.com/tuan/bulletin/#{article.id}"} if article.article_category.tp < 0
        post = Post.create_post(params,user)
        if params[:from]
          post.from = params[:from]
          post.save
        end
      end
    end
    comment
  end
  
  def self.json_methods
    [:user]
  end 
  
  def as_json(options = {})
    options[:methods] ||= ArticleComment.json_methods
    super options
  end
  
end
