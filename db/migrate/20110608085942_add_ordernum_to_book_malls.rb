class AddOrdernumToBookMalls < ActiveRecord::Migration
  def self.up
    add_column :book_malls, :order_number, :integer, :default => -1
  end

  def self.down
    remove_column :book_malls, :order_number	
  end
end
