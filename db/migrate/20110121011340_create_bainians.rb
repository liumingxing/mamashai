class CreateBainians < ActiveRecord::Migration
  def self.up
    create_table :bainians do |t|
      t.integer :user_id
      t.string :logo, :limit=>200
      t.string :role_name, :limit=>200
      t.timestamps
    end
    
    add_index :bainians, :user_id
  end

  def self.down
    drop_table :bainians
  end
end
