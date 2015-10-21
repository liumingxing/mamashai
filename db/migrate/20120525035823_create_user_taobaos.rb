class CreateUserTaobaos < ActiveRecord::Migration
  def self.up
    create_table :user_taobaos do |t|
      t.integer :user_id
      t.string  :taobao_id
      t.string  :taobao_nick
      t.integer :expire_at
      t.string  :refresh_token
      t.integer :re_expire_at
      t.string  :mobile_token
      t.string  :access_token
      t.timestamps
    end
  end

  def self.down
    drop_table :user_taobaos
  end
end
