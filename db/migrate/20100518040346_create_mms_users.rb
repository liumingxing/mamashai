class CreateMmsUsers < ActiveRecord::Migration
  def self.up
    create_table :mms_users do |t|
      t.string :username
      t.string :password
      t.string :power
      t.datetime :created_at
    end
    
    Mms::User.create(:username => 'admin', :password => 'admin', :power => '超级管理员')
  end

  def self.down
    drop_table :mms_users
  end
end
