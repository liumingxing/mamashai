class AddContent1ToUserBookPages < ActiveRecord::Migration
  def self.up
    add_column :user_book_pages, :content1, :string, :limit=>230
    add_column :user_book_pages, :content2, :string, :limit=>230
    add_column :user_book_pages, :content3, :string, :limit=>230
  end

  def self.down
  end
end
