class CreateGouSites < ActiveRecord::Migration
  def self.up
    create_table :gou_sites do |t|
      t.string  :name
      t.string  :url
      t.string  :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :gou_sites
  end
end