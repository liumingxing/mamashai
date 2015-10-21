class AddResultToApnMessage < ActiveRecord::Migration
  def self.up
  	add_column :apn_messages, :result, :string
  end

  def self.down
  end
end
