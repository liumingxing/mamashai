class CreateShoppingCarts < ActiveRecord::Migration
  def self.up
    create_table :shopping_carts do |t|
      t.integer :user_id
      t.text :shopping_items

      t.timestamps
    end
  end

  def self.down
    drop_table :shopping_carts
  end
end
