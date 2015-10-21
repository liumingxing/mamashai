class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books  do |t|
      t.string :book_name
      t.string :book_site
      t.string :book_author
      t.integer :translator_id
      t.string :publishing_house
      t.integer :brand_id
      t.string :paperback
      t.string :series_book_ids
      t.text :unite_recommend
      t.text :book_summary
      t.text :author_summary
      t.text :media_view
      t.integer :gou_site_id
      t.string :buy_url

      t.timestamps
    end

    add_index :books, :book_name
  end

  def self.down
    drop_table :books
  end
end
