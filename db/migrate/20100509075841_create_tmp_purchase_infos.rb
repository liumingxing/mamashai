class CreateTmpPurchaseInfos < ActiveRecord::Migration
  def self.up
    create_table :tmp_purchase_infos do |t|
      t.integer :amount
      t.string :money
      t.string :pay_person
      t.string :receive_person
      t.string :address
      t.string :postcode
      t.string :mobile
      t.string :email
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :tmp_purchase_infos
  end
end
