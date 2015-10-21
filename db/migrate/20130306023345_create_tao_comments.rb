class CreateTaoComments < ActiveRecord::Migration
  def self.up
    create_table :tao_comments do |t|
      t.integer :user_id
      t.string :user_name, :limit=>30
      t.string :user_logo, :limit=>30
      t.integer :product_id
      t.integer :post_id
      t.string :content, :limit=>250
      t.timestamps
    end

    add_index :tao_comments, [:user_id, :user_name, :product_id], :unique=>true
  end

  def self.down
    drop_table :tao_comments
  end
end
