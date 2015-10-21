class AddPayAtToAlbumOrders < ActiveRecord::Migration
  def self.up
    add_column :album_orders, :pay_at, :time
  end

  def self.down
  end
end
