class AddToSinaToMamshaiUserWeibo < ActiveRecord::Migration
  def self.up
    add_column :user_weibos, :to_sina, :boolean, :default=>true, :null=>true
    add_column :user_weibos, :to_mamashai, :boolean, :default=>true, :null=>true
  end

  def self.down
  end
end
