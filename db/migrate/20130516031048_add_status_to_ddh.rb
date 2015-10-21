class AddStatusToDdh < ActiveRecord::Migration
  def self.up
  	add_column :ddhs, :status, :integer
  end

  def self.down
  end
end
