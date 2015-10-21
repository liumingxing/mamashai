class AddTopicSubjectIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :subjects, :deputy_user_id, :integer
    add_index :subjects, :deputy_user_id
  end

  def self.down
    remove_column :subjects, :deputy_user_id
    remove_index :subjects, :deputy_user_id
  end
end
