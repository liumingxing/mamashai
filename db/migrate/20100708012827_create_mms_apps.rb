class CreateMmsApps < ActiveRecord::Migration
  def self.up
    create_table :mms_apps do |t|
      t.string :logo
      t.string :name
      t.string :url
      t.text :content
      t.string :icon
      t.boolean :is_system_components, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mms_apps
  end
end
