class CommentAtRemind < ActiveRecord::Migration
  def self.up
  	create_table :comment_at_reminds do |t|
  		t.integer :comment_id
  		t.integer :user_id
  	end
  	add_index :comment_at_reminds, :comment_id
  	add_index :comment_at_reminds, :user_id
  end

  def self.down

  end
end
