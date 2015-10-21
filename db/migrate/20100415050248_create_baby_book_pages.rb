class CreateBabyBookPages < ActiveRecord::Migration
  def self.up
    create_table :baby_book_pages do |t|
      t.string :name,:limit=>100
      t.string :logo,:limit=>50
      t.integer :baby_book_id
      t.integer :position
      t.text :content
      t.text :content_history
      t.integer :layout_id

      t.timestamps
    end
  end

  def self.down
    drop_table :baby_book_pages
  end
end
