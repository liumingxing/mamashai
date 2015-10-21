class AddClapsCountToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :claps_count, :integer, :default=>0, :null=>false
  end

  def self.down
    remove_column :posts, :claps_count
  end
end
