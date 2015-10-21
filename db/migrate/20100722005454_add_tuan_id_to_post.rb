class AddTuanIdToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :tuan_id, :integer
  end

  def self.down
    remove_column :posts, :tuan_id
  end
end
