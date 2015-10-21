class CreateSuppliers < ActiveRecord::Migration
  def self.up
    create_table :suppliers do |t|
      t.string :code, :limit=>12
      t.string :name
      t.string :password, :limit=>12
      t.string :address
      t.string :phone, :limit=>20
      t.column :mobile,"bigint unsigned"
      t.string :email, :limit=>60
      t.string :contacter

      t.timestamps
    end
  end

  def self.down
    drop_table :suppliers
  end
end
