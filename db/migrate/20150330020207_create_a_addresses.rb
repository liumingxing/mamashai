class CreateAAddresses < ActiveRecord::Migration
  def change
    create_table :a_addresses do |t|
      t.integer :user_id
      t.string :receiver
      t.string :mobile
      t.string :city
      t.string :address
      t.boolean :default
      t.string :id_name
      t.string :id_code
      t.string :id_logo1
      t.string :id_logo2

      t.timestamps
    end
  end
end
