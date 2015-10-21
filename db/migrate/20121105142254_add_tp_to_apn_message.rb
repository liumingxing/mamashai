class AddTpToApnMessage < ActiveRecord::Migration
  def self.up
  	add_column :apn_messages, :tp, :integer
  end

  def self.down
  end
end
