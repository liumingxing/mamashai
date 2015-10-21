class CreateUserRewards < ActiveRecord::Migration
  def self.up
    create_table :user_rewards, :force => true do |t|
      t.string :reward,:limit=>30
      t.integer :user_id
      t.date :get_reward_at
      t.datetime :created_at
    end
    add_index :user_rewards, :user_id
  end

  def self.down
     drop_table :user_rewards
  end
end
