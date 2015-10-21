class AddPmtIgnoresToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :pmt_ignores, :string, :limit=>30,:default=>''
  end

  def self.down
  end
end
