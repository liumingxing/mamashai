class CreateBlockcomments < ActiveRecord::Migration
  def change
    create_table :blockcomments do |t|
      t.integer :user_id1
      t.string  :user_name1
      t.integer :user_id2
      t.string  :user_name2
      t.timestamps
    end
  end
end
