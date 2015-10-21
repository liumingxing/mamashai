class CreateBookVisits < ActiveRecord::Migration
  def self.up
    create_table :book_visits do |t|
      t.integer :book_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :book_visits
  end
end
