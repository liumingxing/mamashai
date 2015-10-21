class FavoriteTuan < ActiveRecord::Base
  belongs_to :user
  belongs_to :tuan,:counter_cache => true
  
  validates_presence_of :user_id, :tuan_id
  
  def self.create_favorite_tuan(tuan,user,params)
    favorite_tuan = FavoriteTuan.new(params[:favorite_tuan])
      ActiveRecord::Base.transaction do
        unless FavoriteTuan.find_by_user_id_and_tuan_id(user.id,tuan.id)
          favorite_tuan.user_id = user.id
          favorite_tuan.tuan_id = tuan.id
          favorite_tuan.save
        end  
      end 
      favorite_tuan
  end
  
  def self.delete_favorite_tuan(params,user)
    ActiveRecord::Base.transaction do
      favorite_tuan = FavoriteTuan.find_by_id_and_user_id(params[:id],user.id)
      favorite_tuan.destroy if favorite_tuan
    end
  end
end
