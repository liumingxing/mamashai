class CreateGamesLianliankans < ActiveRecord::Migration
  def self.up
    create_table :games_lianliankans do |t|
      t.integer :user_id
      t.string :name
      t.text :info
      t.string :logo,:limit=>200
      t.integer :players_count, :default=>0
      t.integer :users_count, :default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :games_lianliankans
  end
end
