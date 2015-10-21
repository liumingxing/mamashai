class AddStepToEbookTopics < ActiveRecord::Migration
  def self.up
    add_column :ebook_topics, :step_id, :string
  end

  def self.down
    remove_column :ebook_topics, :step_id
  end
end
