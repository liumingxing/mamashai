class CreateAReports < ActiveRecord::Migration
  def change
    create_table :a_reports do |t|
      t.integer :code
      t.integer :a_product_id
      t.string :brand
      t.string :product_name
      t.string :product_name_eng
      t.float  :price
      t.float  :price_market_yuan
      t.float  :price_market_aus
      t.integer :count
      t.date   :date
      t.timestamps
    end
  end
end
