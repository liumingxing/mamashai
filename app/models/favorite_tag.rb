class FavoriteTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  
  validates_presence_of :user_id
  validates_presence_of :tag_id
  
  def self.create_favorite_tag(tag,user)
    unless FavoriteTag.find_by_user_id_and_tag_id(user.id,tag.id)
      FavoriteTag.create(:user_id=>user.id,:tag_id=>tag.id)
    end  
  end
  
  def self.create_favorite_tags(tag_ids,user)
    ActiveRecord::Base.transaction do
      tag_ids.each do |tag_id|
        self.create_favorite_tag(Tag.find(tag_id),user)
      end
    end
  end
  
end
