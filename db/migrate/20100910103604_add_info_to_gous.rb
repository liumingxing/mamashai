class AddInfoToGous < ActiveRecord::Migration
  def self.up
    add_column :gous, :info, :string
  end

  def self.down
    remove_column :gous, :info
  end
end
