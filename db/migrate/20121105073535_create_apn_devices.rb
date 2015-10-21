class CreateApnDevices < ActiveRecord::Migration
  def self.up
    create_table :apn_devices do |t|
      t.integer :user_id
      t.string :device_token
      t.boolean :active, :default=>true
      t.string :alias
      t.integer :tp
      t.timestamps
    end

    add_index "apn_devices", ["device_token"], :name => "device_token", :unique => true
  end

  def self.down
    drop_table :apn_devices
  end
end
