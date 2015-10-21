class CreateFrightProfiles < ActiveRecord::Migration
  def self.up
    create_table :fright_profiles do |t|
      t.string :name
      t.decimal :fee, :precision => 8, :scale => 2
      t.string :info

      t.timestamps
    end
    add_column :tuans,:weight,:decimal, :precision => 8, :scale => 2,:default=>0.0
  end

  def self.down
    remove_column :tuans,:weight
    drop_table :fright_profiles
  end
end
