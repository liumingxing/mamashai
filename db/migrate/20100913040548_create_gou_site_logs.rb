class CreateGouSiteLogs < ActiveRecord::Migration
  def self.up
    create_table :gou_site_logs do |t|
      t.integer :user_id
      t.integer :gou_id
      t.integer :gou_site_id
      t.string :gou_site_name
      t.string :user_name
      t.string :url
      t.string :log

      t.timestamps
    end
  end

  def self.down
    drop_table :gou_site_logs
  end
end
