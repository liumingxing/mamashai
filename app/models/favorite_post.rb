class FavoritePost < ActiveRecord::Base
  belongs_to :user
  belongs_to :post,:counter_cache => true
  
  validates_presence_of :user_id
  validates_presence_of :post_id
  
  def self.create_favorite_post(post,user,params)
    favorite_post = FavoritePost.new(params[:favorite_post])
    ActiveRecord::Base.transaction do
      unless FavoritePost.find_by_user_id_and_post_id(user.id,post.id)
        favorite_post.user_id = user.id
        favorite_post.post_id = post.id
        favorite_post.save
        if post.user_id != user.id 
          MamashaiTools::ToolUtil.add_unread_infos(:create_favorite_post,{:user=>post.user})
        end
      end  
    end 
    favorite_post
  end
  
  def self.delete_favorite_post(params,user)
    ActiveRecord::Base.transaction do
      favorite_post = FavoritePost.find_by_post_id_and_user_id(params[:id],user.id)
      favorite_post.destroy
    end
  end
  
  def self.find_posts_favorites(params,post)
    FavoritePost.paginate(:per_page => params[:per_page]||25,:conditions=>['favorite_posts.post_id=?',post.id],:page => params[:page]||1,:include=>[:user],:order => "favorite_posts.id desc")
  end
  
  def self.find_other_user_favorites(params,user)
    MamashaiTools::ToolUtil.clear_unread_infos(user,:unread_favorites_count)
    FavoritePost.paginate(:per_page => params[:per_page]||25,:conditions=>['posts.user_id=? and favorite_posts.user_id<>?',user.id,user.id],:page => params[:page]||1,:include=>[:user,:post],:order => "favorite_posts.id desc")
  end
  
end
