class AddMfnIdToEbookTopics < ActiveRecord::Migration
  def self.up
    add_column :ebook_topics, :mfn_id, :integer
  end

  def self.down
    add_column :ebook_topics, :mfn_id
  end
end
