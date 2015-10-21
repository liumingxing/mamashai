class AddPostUserIdToComments < ActiveRecord::Migration
  def self.up
  	add_column :comments, :post_user_id, :integer
  	add_index :comments, :post_user_id
  end

  def self.down
  end
end
