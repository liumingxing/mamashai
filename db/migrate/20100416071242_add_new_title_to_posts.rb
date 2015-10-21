class AddNewTitleToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :new_title, :string, :limit=>150
    add_column :posts, :new_title_user_id, :integer
    add_column :ages, :angle_user_ids, :string, :limit=>100
  end
  
  def self.down
    remove_column :posts, :new_title
    remove_column :posts, :new_title_user_id
    remove_column :ages, :angle_user_ids
  end
end
