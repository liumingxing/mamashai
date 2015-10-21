class CreateAdvertisements < ActiveRecord::Migration
  def self.up
    create_table :advertisements do |t|
      t.integer :position, :null => false
      t.string :description
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :advertisements
  end
end
