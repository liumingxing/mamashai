class AddTpToTuanWebsites < ActiveRecord::Migration
  def self.up
    add_column :tuan_websites, :tp, :integer, :default=>0
    add_column :tuan_websites, :icp, :string
    add_column :tuan_websites, :icp_bei, :string
    add_column :tuan_websites, :note, :string
    add_column :tuan_websites, :profile, :string
  end

  def self.down
    remove_column :tuan_websites, :tp
    remove_column :tuan_websites, :icp
    remove_column :tuan_websites, :icp_bei
    remove_column :tuan_websites, :note
    remove_column :tuan_websites, :profile
  end
end
