class AddWeiboToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :sina_weibo_id, :string
    add_column :comments, :tencent_weibo_id, :string
  end

  def self.down
    remove_column :comments, :sina_weibo_id
    remove_column :comments, :tencent_weibo_id
  end
end
