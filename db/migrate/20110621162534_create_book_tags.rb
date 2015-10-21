class CreateBookTags < ActiveRecord::Migration
  def self.up
    create_table :book_tags do |t|
      t.integer :book_id
      t.integer :tag_id

      t.timestamps
    end

    add_index :book_tags, [:book_id, :tag_id]
    add_index :book_tags, :tag_id
  end

  def self.down
    drop_table :book_tags
  end
end
