class CreateUserWeibos < ActiveRecord::Migration
  def self.up
    create_table :user_weibos do |t|
      t.integer :user_id
      t.string :access_id
      t.string :access_token
      t.string :access_secret
      t.integer :tp  #1为 sina
      t.timestamps
    end
    add_index :user_weibos, :user_id
    add_index :user_weibos, :access_id
  end

  def self.down
    drop_table :user_weibos
  end
end
