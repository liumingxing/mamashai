class CreateBlocknames < ActiveRecord::Migration
  def change
    create_table :blocknames do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
