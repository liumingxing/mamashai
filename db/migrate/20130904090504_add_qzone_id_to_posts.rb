class AddQzoneIdToPosts < ActiveRecord::Migration
  def self.up
  	add_column :posts, :qzone_id, :string
  end

  def self.down
  end
end
