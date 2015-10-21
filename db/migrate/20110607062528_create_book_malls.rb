class CreateBookMalls < ActiveRecord::Migration
  def self.up
    create_table :book_malls do |t|
      t.integer :book_id
      t.integer :gou_site_id
      t.string :book_mall_url

      t.timestamps
    end
  end

  def self.down
    drop_table :book_malls
  end
end
