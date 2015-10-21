class AddCountToSubjectUsers < ActiveRecord::Migration
  def self.up
    add_column :subject_users, :subject_posts_count, :integer, :default=>0
    add_column :subject_users, :week_subject_posts_count, :integer, :default=>0
  end

  def self.down
    remove_column :subject_users, :week_subject_posts_count
    remove_column :subject_users, :subject_posts_count
  end
end
