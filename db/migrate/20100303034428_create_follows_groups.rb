class CreateFollowsGroups < ActiveRecord::Migration
  def self.up
    create_table :follows_groups do |t|
      t.string :name,:limit=>20
      t.integer :user_id
      t.integer :users_count,:default=>0

    end
  end

  def self.down
    drop_table :follows_groups
  end
end
