class Rename139idToId139 < ActiveRecord::Migration
  def self.up
    rename_column :posts,'139id','id_139'
  end

  def self.down
  end
end
