class CreateAlbumOrders < ActiveRecord::Migration
  def self.up
    create_table :album_orders do |t|
      t.integer :book_id
      t.integer :user_id
      t.string :status
      t.string :address
      t.string :telephone
      t.string :linkname
      t.string :postcode
      t.integer :price
      t.timestamps
    end
  end

  def self.down
    drop_table :album_orders
  end
end
