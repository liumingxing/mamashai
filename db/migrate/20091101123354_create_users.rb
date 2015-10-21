class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :email,:limit=>35
      t.string :password,:limit=>35
      t.string :logo,:limit=>20
      t.string :name,:limit=>25 
      t.string :domain,:limit=>25
      t.string :gender,:limit=>2
      t.integer :birthyear
      t.date :birthday
      t.string :job_title,:limit=>50
      t.string :msn,:limit=>30
      t.string :qq,:limit=>20
      t.string :mobile,:limit=>20
      t.string :age_ids,:limit=>20,:default=>''
      t.string :tag_ids,:limit=>200,:default=>''
      t.integer :tp,:default=>0
      t.integer :score,:default=>0
      t.integer :skin,:default=>1 
      t.integer :user_kids_count,:default=>0
      t.integer :follow_users_count,:default=>0
      t.integer :fans_users_count,:default=>0
      t.integer :posts_count,:default=>0
      t.integer :unread_fans_count,:default=>0
      t.integer :unread_comments_count,:default=>0
      t.integer :unread_answers_count,:default=>0
      t.integer :unread_messages_count,:default=>0
      t.integer :unread_gifts_count,:default=>0
      t.integer :unread_atme_count,:default=>0
      t.integer :last_post_id
      t.integer :first_kid_id
      t.integer :province_id
      t.integer :city_id
      t.integer :industry_id
      t.datetime :created_at
      t.datetime :last_login_at
      t.string :last_login_ip
    end
    
    add_index :users, :email
    add_index :users, :name
    add_index :users, :mobile
    add_index :users, :domain
    add_index :users, :msn
    add_index :users, :province_id
    add_index :users, :city_id
    add_index :users, :posts_count
    add_index :users, :fans_users_count
    add_index :users, :tp
    
  end
  
  def self.down
    drop_table :users
  end
end
