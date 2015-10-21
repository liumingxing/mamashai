class AddMemoToAlbumOrder < ActiveRecord::Migration
  def self.up
  	add_column :album_orders, :memo, :string
  end

  def self.down
  end
end
