class CreateTaoAgeTaoProducts < ActiveRecord::Migration
  def change
    create_table :tao_ages_tao_products do |t|
      t.integer :tao_age_id
      t.integer :tao_product_id
      t.timestamps
    end

    add_index :tao_ages_tao_products, [:tao_age_id, :tao_product_id]
  end
end
