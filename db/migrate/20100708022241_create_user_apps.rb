class CreateUserApps < ActiveRecord::Migration
  def self.up
    create_table :user_apps do |t|
      t.references :user
      t.references :mms_app
      t.integer :position
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :user_apps
  end
end
