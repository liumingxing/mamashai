class AddTpToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :tp, :integer, :default=>0
    add_column :posts, :title, :string, :limit=>100
    Post.update_all("tp=0")
  end

  def self.down
    remove_column :posts, :title
    remove_column :posts, :tp
  end
end
