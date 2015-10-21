class CreateBabyBookVotes < ActiveRecord::Migration
  def self.up
    create_table :baby_book_votes do |t|
      t.string :ip,:limit=>50
      t.integer :vote_value,:default=>1
      t.integer :user_id
      t.integer :baby_book_id
      t.datetime :created_at
    end
    add_column :baby_books, :is_match, :boolean, :default=>false
    add_column :baby_books, :vote_count, :integer, :default=>0
  end

  def self.down
    drop_table :baby_book_votes
    remove_column :baby_books, :is_match
    remove_column :baby_books, :vote_count
  end
end
