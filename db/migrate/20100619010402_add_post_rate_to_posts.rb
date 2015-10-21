class AddPostRateToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_rate, :integer
  end

  def self.down
    remove_column :posts, :post_rate
  end
end
