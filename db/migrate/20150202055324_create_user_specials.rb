class CreateUserSpecials < ActiveRecord::Migration
  def change
    create_table :user_specials do |t|
      t.integer :user_id
      t.string :user_name
      t.string :tp
      t.timestamps
    end
  end
end
