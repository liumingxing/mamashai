class AddSpotIdToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :spot_id, :integer
  end

  def self.down
    remove_column :posts, :spot_id
  end
end
