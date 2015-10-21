class AddKdToAlbumOrders < ActiveRecord::Migration
  def self.up
    add_column :album_orders, :kd, :string
  end

  def self.down
  end
end
