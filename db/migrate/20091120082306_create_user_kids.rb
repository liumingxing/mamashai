class CreateUserKids < ActiveRecord::Migration
  def self.up
    create_table :user_kids, :force => true do |t|
      t.string :name,:limit=>50
      t.string :logo,:limit=>50
      t.string :gender,:limit=>2
      t.string :education,:limit=>20
      t.string :education_org,:limit=>200
      t.string :content,:limit=>210
      t.integer :star
      t.integer :user_id
      t.date :birthday
      t.datetime :created_at
    end
    
    add_index :user_kids, :user_id
    
  end

  def self.down
    drop_table :user_kids
  end
end
