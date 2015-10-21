class AddPostRatesCountToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_rates_count, :integer, :default=>0
  end

  def self.down
  end
end
