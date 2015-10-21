class CreateSpideProgress < ActiveRecord::Migration
  def self.up
    create_table :spide_progress do |t|
      t.integer :site_id
      t.string :url, :limit=>200
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :spide_progress
  end
end
