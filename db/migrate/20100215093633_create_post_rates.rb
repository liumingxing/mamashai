class CreatePostRates < ActiveRecord::Migration
  def self.up
    create_table :post_rates, :force => true do |t|
      t.integer :rate
      t.integer :post_id
      t.integer :post_user_id
      t.integer :user_id
    end
    add_index :post_rates, :post_id
    add_index :post_rates, :post_user_id
  end

  def self.down
  end
end
