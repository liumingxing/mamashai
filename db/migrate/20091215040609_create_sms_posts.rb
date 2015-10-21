class CreateSmsPosts < ActiveRecord::Migration
  def self.up
    create_table :sms_posts, :force => true do |t|
      t.string :sid,:limit=>20  
      t.string :sno,:limit=>20
      t.string :stxt,:limit=>210
      t.datetime :stime
      t.datetime :created_at
      t.integer :post_id
    end
  end

  def self.down
    drop_table :sms_posts
  end
end
