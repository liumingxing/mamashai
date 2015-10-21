class CreateUserQzones < ActiveRecord::Migration
  def self.up
    create_table :user_qzones do |t|
      t.integer :user_id
      t.string :openid
      t.string :nick
      t.string :access_token
      t.string :access_secret
      t.integer :tp
      t.integer :expire_at
      t.timestamps
    end

    add_index :user_qzones, :user_id
    add_index :user_qzones, :openid
  end

  def self.down
    drop_table :user_qzones
  end
end
