class AddNumberToGous < ActiveRecord::Migration
  def self.up
    add_column :gous, :number, :integer
  end

  def self.down
    remove_column :gous, :number
  end
end
