class CreateAdvs < ActiveRecord::Migration
  def self.up
    create_table :advs do |t|
      t.string :link, :limit=>200
      t.string :logo, :limit=>200
      t.string :desc, :limit=>200
      t.integer :price
      t.integer :tp
      t.boolean :hide, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :advs
  end
end
