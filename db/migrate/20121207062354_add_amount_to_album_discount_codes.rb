class AddAmountToAlbumDiscountCodes < ActiveRecord::Migration
  def self.up
    add_column :album_discount_codes, :amount, :integer, :default=>5, :null=>false
  end

  def self.down
  end
end
