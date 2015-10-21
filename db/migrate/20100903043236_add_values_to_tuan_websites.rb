class AddValuesToTuanWebsites < ActiveRecord::Migration
  def self.up
    add_column :tuan_websites, :value_1, :integer
    add_column :tuan_websites, :value_2, :integer
    add_column :tuan_websites, :value_3, :integer
  end

  def self.down
    remove_column :tuan_websites, :value_1
    remove_column :tuan_websites, :value_2
    remove_column :tuan_websites, :value_3
  end
end
