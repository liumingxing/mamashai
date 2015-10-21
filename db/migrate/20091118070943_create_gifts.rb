class CreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts, :force => true do |t|
      t.string :name,:limit=>100
      t.string :logo,:limit=>50
      t.integer :gift_gets_count,:default=>0
      t.integer :score,:default=>0
    end
 
  end

  def self.down
    drop_table :gifts
  end
end
