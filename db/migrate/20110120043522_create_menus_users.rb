class CreateMenusUsers < ActiveRecord::Migration
  def self.up
    create_table :menus_users do |t|
      t.integer :menu_id
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :menus_users
  end
end
