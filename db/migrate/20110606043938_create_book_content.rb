class CreateBookContent < ActiveRecord::Migration
  def self.up
    create_table :book_contents do |t|
      t.text :content
      t.integer :book_id

      t.timestamps
    end
  end

  def self.down
    drop_table :book_contents
  end
end
