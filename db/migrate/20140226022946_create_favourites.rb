class CreateFavourites < ActiveRecord::Migration
  def self.up
    create_table :favourites do |t|
      t.integer :user_id
      t.string :tp, :length=>20
      t.integer :tp_id
      t.datetime :created_at
    end

    add_index :favourites, [:user_id, :tp_id, :tp], :unique=>true
  end

  def self.down
  	drop_table :favourites
  end
end
