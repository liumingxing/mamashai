class AddPost1IdToUserBookPages < ActiveRecord::Migration
  def self.up
    add_column :user_book_pages, :post1_id, :integer
    add_column :user_book_pages, :post2_id, :integer
    add_column :user_book_pages, :post3_id, :integer
  end

  def self.down
  end
end
