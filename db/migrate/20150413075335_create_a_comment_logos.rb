class CreateACommentLogos < ActiveRecord::Migration
  def change
    create_table :a_comment_logos do |t|
      t.integer :a_comment_id
      t.integer :user_id
      t.integer :a_product_id
      t.string :logo
      t.timestamps
    end
  end
end
