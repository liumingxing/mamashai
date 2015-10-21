class AddGoodCountViewCountStateCommentCounts < ActiveRecord::Migration
  def self.up
    add_column :books, :view_count, :integer, :default => 0
    add_column :books, :good_count, :integer, :default => 0
    add_column :books, :comment_count, :integer, :default => 0
  end

  def self.down
    remove_column :books, :view_count, :good_count, :comment_count
  end
end
