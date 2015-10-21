class AddTuiguangToArticles < ActiveRecord::Migration
  def self.up
  	add_column :articles, :tuiguang_text, :string
  	add_column :articles, :tuiguang_url, :string
  end

  def self.down
  	remove_column :articles, :tuiguang_text
  	remove_column :articles, :tuiguang_url
  end
end
