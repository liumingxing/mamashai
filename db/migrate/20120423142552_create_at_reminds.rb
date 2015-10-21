class CreateAtReminds < ActiveRecord::Migration
  def self.up
    create_table :at_reminds do |t|
      t.integer :post_id
      t.integer :user_id
      t.timestamps
    end
 
    add_index :at_reminds, :post_id
    add_index :at_reminds, :user_id
    add_index :at_reminds, [:post_id, :user_id], :unique=>true
  end

  def self.down
    drop_table :at_reminds
  end
end
