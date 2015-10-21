class AddRidToTuanComments < ActiveRecord::Migration
  def self.up
#    add_column :tuan_comments, :rid, :string, :limit => 32
  end

  def self.down
    remove_column :tuan_comments, :rid
  end
end
