class CreateTuanSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :tuan_subscriptions do |t|
      t.string :email, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_subscriptions
  end
end
