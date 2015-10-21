class CreateAppleComments < ActiveRecord::Migration
  def self.up
    create_table :apple_comments do |t|
      t.string :name
      t.integer :score
      t.integer :user_id
      t.timestamps
    end

    add_index :apple_comments, :name, :unique=>true
  end

  def self.down
    drop_table :apple_comments
  end
end
