class AddColumnLogoToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :logo, :string
  end

  def self.down
    remove_column :articles, :logo
  end
end
