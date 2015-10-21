class CreateAPayments < ActiveRecord::Migration
  def change
    create_table :a_payments do |t|
      t.integer :order_id
      t.string :trade_no
      t.string :buyer_id
      t.string :buyer_email
      t.string :subject
      t.float :price
      t.string :status
      t.string :seller_email
      t.string :notify_id
      t.string :use_coupon
      t.timestamps
    end
  end
end
