class CreateAproducts < ActiveRecord::Migration
  def change
    create_table :aproducts do |t|
      t.integer :category_id
      t.string :code
      t.string :for_age
      t.string :introduce
      t.string :name
      t.string :logo
      t.float  :price
      t.float  :o_price
      t.string :from
      t.string :remark
      t.string :brand
      t.string :weight
      t.string :fee
      t.text   :detail
      t.integer :remain
      t.integer :sell_total, :default=>0
      t.integer :sell_month, :default=>0
      t.integer :sell_week, :default=>0
      t.integer :acomments_count, :default=>0
      t.timestamps
    end
  end
end
