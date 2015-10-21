class AddCountToAlbumOrder < ActiveRecord::Migration
  def self.up
    add_column :album_orders, :book_count, :integer, :default=>1
  end

  def self.down
  end
end
