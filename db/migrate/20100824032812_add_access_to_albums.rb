class AddAccessToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :access, :string, :default => "public"
  end

  def self.down
    remove_column :albums, :access
  end
end
