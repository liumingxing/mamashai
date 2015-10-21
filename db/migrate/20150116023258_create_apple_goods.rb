class CreateAppleGoods < ActiveRecord::Migration
  def change
    create_table :apple_goods do |t|
      t.string :title
      t.string :name
      t.string :content, :length=>400
      t.date :occur
      t.timestamps
    end
  end
end
