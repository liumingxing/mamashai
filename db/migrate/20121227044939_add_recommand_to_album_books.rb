class AddRecommandToAlbumBooks < ActiveRecord::Migration
  def self.up
    add_column :album_books, :recommand, :boolean, :default=>false
  end

  def self.down
  end
end
