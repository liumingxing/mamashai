class ColumnVisits < ActiveRecord::Migration
  def self.up
    create_table :column_visits do |t|
      t.integer :author_id
      t.integer :book_id
      t.integer :chapter_id
      t.integer :visitor_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :column_visits
  end
end
