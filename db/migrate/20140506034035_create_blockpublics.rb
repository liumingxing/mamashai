class CreateBlockpublics < ActiveRecord::Migration
  def change
    create_table :blockpublics do |t|
	  t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
