class AddSinaWeiboIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :sina_weibo_id, :string
    add_index :posts, :sina_weibo_id
  end

  def self.down
    remove_index :posts, :sina_weibo_id
    remove_column :posts, :sina_weibo_id
  end
end
