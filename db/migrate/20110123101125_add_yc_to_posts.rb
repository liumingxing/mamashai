class AddYcToPosts < ActiveRecord::Migration
  def self.up
    #发言是否原创
    add_column :posts, :yc, :boolean
  end

  def self.down
    remove_column :posts, :yc
  end
end
