class CreateBbrlUsers < ActiveRecord::Migration
  def self.up
    create_table :bbrl_users do |t|
      t.string :app_id
      t.string :name
      t.string :address
      t.string :youbian
      t.integer :mobile

      t.timestamps
    end
  end

  def self.down
    drop_table :bbrl_users
  end
end
