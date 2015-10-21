class AddToQqToMamashaiUserQq < ActiveRecord::Migration
  def self.up
    add_column :user_qqs, :to_qq, :boolean, :default=>true, :null=>true
    add_column :user_qqs, :to_mamashai, :boolean, :default=>true, :null=>true
  end

  def self.down
  end
end
