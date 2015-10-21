class CreatePostLogos < ActiveRecord::Migration
  def change
    create_table :post_logos do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :logo
      t.timestamps
    end

    add_index :post_logos, :post_id
    add_index :post_logos, :user_id
  end
end
