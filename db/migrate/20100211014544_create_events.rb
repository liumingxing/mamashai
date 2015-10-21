class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events, :force => true do |t|
      t.string :name,:limit=>60
      t.integer :event_tag_id
      t.integer :province_id
      t.integer :city_id
      t.integer :status, :default=>0
      t.string :location,:limit=>80 
      t.float :longitude
      t.float :latitude
      t.string :age_ids,:limit=>100
      t.integer :pay_fee
      t.integer :limit_num
      t.integer :posts_count,:default=>0
      t.integer :event_users_count,:default=>0
      t.integer :join_users_count,:default=>0
      t.integer :event_pictures_count,:integer,:default=>0
      t.text :content
      t.string :cancel_reason,:limit=>200
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :created_at
      t.integer :spot_id
      t.integer :post_id
      t.integer :user_id
    end
    add_index :events, :start_at
    add_index :events, :province_id
    add_index :events, :city_id
  end
  
  def self.down
  end
end
