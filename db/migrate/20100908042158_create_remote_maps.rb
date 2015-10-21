class CreateRemoteMaps < ActiveRecord::Migration
  def self.up
    create_table :remote_maps do |t|
      t.string :local_tab
      t.integer :local_id
      t.string :remote_tab
      t.integer :remote_id

      t.timestamps
    end
  end

  def self.down
    drop_table :remote_maps
  end
end
