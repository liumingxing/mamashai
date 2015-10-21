class CreateBestFollowUsers < ActiveRecord::Migration
  def self.up
    create_table :best_follow_users do |t|
      t.integer :follow_user_id
      t.integer :user_id
      t.integer :order_num,:default=>0
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :best_follow_users
  end
end
