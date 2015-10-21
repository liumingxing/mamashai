class AddGouIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :gou_id, :integer
  end

  def self.down
    remove_column :posts, :gou_id
  end
end
