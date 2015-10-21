class AddUserNameToEbookTopics < ActiveRecord::Migration
  def self.up
    add_column :ebook_topics, :username, :string, :limit=>100
    add_column :ebook_topics, :userdesc, :string, :limit=>400
  end

  def self.down
  end
end
