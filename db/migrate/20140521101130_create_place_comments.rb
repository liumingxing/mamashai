class CreatePlaceComments < ActiveRecord::Migration
  def change
    create_table :place_comments do |t|
      t.string :business_id
      t.integer :user_id
      t.integer :rate
      t.string :shiyi
      t.string :qx
      t.string :content
	  t.timestamps
    end
  end
end
