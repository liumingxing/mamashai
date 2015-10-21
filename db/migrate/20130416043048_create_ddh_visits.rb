class CreateDdhVisits < ActiveRecord::Migration
  def self.up
    create_table :ddh_visits do |t|
      t.integer :user_id
      t.integer :ddh_id
      t.string :ip
      t.timestamps
    end

    add_index :ddh_visits, :user_id
    add_index :ddh_visits, :ddh_id
  end

  def self.down
    drop_table :ddh_visits
  end
end
