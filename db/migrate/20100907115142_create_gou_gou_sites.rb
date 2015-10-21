class CreateGouGouSites < ActiveRecord::Migration
  def self.up
    create_table :gou_gou_sites do |t|
      t.integer :gou_id
      t.integer :gou_site_id
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :click_count,:default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :gou_gou_sites
  end
end
