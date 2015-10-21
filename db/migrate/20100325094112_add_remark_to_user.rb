class AddRemarkToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :remark, :string
  end

  def self.down
    remove_column :users, :remark
  end
end
