class CreateVisitUsers < ActiveRecord::Migration
  def self.up
    create_table :visit_users do |t|
      t.integer :visit_user_id
      t.integer :user_id
      t.datetime :created_at
    end
    
    add_index :visit_users, :user_id
    
  end
  
  def self.down
    drop_table :visit_users
  end
end

