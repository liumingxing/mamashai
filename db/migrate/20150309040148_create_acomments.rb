class CreateAcomments < ActiveRecord::Migration
  def change
    create_table :acomments do |t|
      t.integer :a_order_id
      t.integer :a_order_detail_id
      t.integer :a_product_id
      t.integer :user_id
      t.string  :text
      t.timestamps
    end
  end
end
