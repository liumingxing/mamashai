class CreateRedPackets < ActiveRecord::Migration
  def change
    create_table :red_packets do |t|
      t.integer :user_id
      t.string :tp
      t.string :zhifubao
      t.integer :score
      t.string  :status, :default=>"wait"
      t.timestamps
    end
  end
end
