class AddRatesCountToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :rates_count, :integer, :default=>0
  end

  def self.down
    remove_column :posts, :rates_count
  end
end
