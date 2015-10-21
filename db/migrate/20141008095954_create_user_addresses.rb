class CreateUserAddresses < ActiveRecord::Migration
  def change
    create_table :user_addresses do |t|
      t.string :user_id
      t.string :name
      t.string :mobile
      t.string :address
      t.string :post_code
      t.timestamps
    end

    add_index :user_addresses, :user_id
  end
end
