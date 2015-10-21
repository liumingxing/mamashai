class CreateMbooks < ActiveRecord::Migration
  def self.up
    create_table :mbooks do |t|
      t.integer :user_id
      t.string :name
      t.string :logo
      t.boolean :publish, :default=>true
      t.text :json
      t.timestamps
    end
  end

  def self.down
    drop_table :mbooks
  end
end
