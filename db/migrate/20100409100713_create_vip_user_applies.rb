class CreateVipUserApplies < ActiveRecord::Migration
  def self.up
    create_table :vip_user_applies, :force => true do |t|
      t.integer :age
      t.integer :age_id
      t.integer :end_age_id
      t.string :gender,:limit=>5
      t.string :net_time,:limit=>50
      t.string :advantage,:limit=>50
      t.string :admin_time,:limit=>50
      t.string :topics,:limit=>200
      t.string :user_names,:limit=>100
      t.string :reason,:limit=>200
      t.string :to_do,:limit=>400
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :vip_user_applies
  end
end
