class AddStateToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :state, :string, :default => "未发布"
  end

  def self.down
    remove_column :books, :state
  end
end
