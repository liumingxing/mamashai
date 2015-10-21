class AddCurrentKeyToTuans < ActiveRecord::Migration
  def self.up
    add_column :tuans, :current_key, :boolean, :defalut=>false
  end

  def self.down
    remove_column :tuans, :current_key
  end
end
