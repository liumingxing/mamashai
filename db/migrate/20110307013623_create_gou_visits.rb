class CreateGouVisits < ActiveRecord::Migration
  def self.up
    create_table :gou_visits do |t|
      t.integer :gou_id
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :gou_visits
  end
end
