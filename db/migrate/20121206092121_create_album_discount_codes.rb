class CreateAlbumDiscountCodes < ActiveRecord::Migration
  def self.up
    create_table :album_discount_codes do |t|
      t.string :code
      t.integer :order_id
      t.timestamps
    end
  end

  def self.down
    drop_table :album_discount_codes
  end
end
