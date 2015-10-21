class CreateUserBaidus < ActiveRecord::Migration
  def self.up
    create_table :user_baidus do |t|
      t.integer :user_id
      t.string :baidu_id
      t.string  :token
      t.string  :secret
      t.datetime :expire_at
      t.string  :refresh_token
      t.integer :tp
      t.timestamps
    end
  end

  def self.down
    drop_table :user_baidus
  end
end
