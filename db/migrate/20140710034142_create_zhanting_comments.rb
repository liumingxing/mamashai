class CreateZhantingComments < ActiveRecord::Migration
  def change
    create_table :zhanting_comments do |t|
      t.integer :user_id
      t.string :content, :length=>400
      t.integer :author_id
      t.timestamps
    end
  end
end
