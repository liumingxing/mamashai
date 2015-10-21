class AddTopicToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :topic, :text
  end

  def self.down
    remove_column :subjects, :topic
  end
end
