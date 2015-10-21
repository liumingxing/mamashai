class CreateTuanComments < ActiveRecord::Migration
  def self.up
    create_table :tuan_comments do |t|
      t.string :content,:limit=>210
      t.datetime :created_at
      t.integer :tuan_id
      t.integer :user_id
      t.integer :rate
      t.index :tuan_id
      t.index :user_id
    end
  end

  def self.down
    drop_table :tuan_comments
  end
end
