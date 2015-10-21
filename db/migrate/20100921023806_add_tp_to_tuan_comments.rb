class AddTpToTuanComments < ActiveRecord::Migration
  def self.up
    add_column :tuan_comments, :tp, :integer
    add_column :tuan_comments, :user_name, :string
    add_column :tuan_comments, :site_name, :string
  end

  def self.down
    remove_column :tuan_comments, :tp
    remove_column :tuan_comments, :user_name
    remove_column :tuan_comments, :site_name
  end
end
