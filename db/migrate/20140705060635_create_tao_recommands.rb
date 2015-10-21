class CreateTaoRecommands < ActiveRecord::Migration
  def change
    create_table :tao_recommands do |t|
      t.integer :tao_product_id
      t.timestamps
    end
  end
end
