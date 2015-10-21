class CreateBabyBookTexts < ActiveRecord::Migration
  def self.up
    create_table :baby_book_texts, :force => true do |t|
      t.integer :post_id
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :baby_book_texts
  end
end
