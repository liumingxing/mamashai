class CreateUserTags < ActiveRecord::Migration
  def self.up
    create_table :user_tags do |t|
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end
    add_index :user_tags, :user_id
    add_index :user_tags, :tag_id
    add_column :tags, :user_tags_count, :integer, :default=>0
    add_index :tags, :user_tags_count
  end

  def self.down
  	remove_index :tags, :user_tags_count
    remove_column :tags, :user_tags_count
    drop_table :user_tags
  end
end
