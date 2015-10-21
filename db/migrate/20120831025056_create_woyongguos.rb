class CreateWoyongguos < ActiveRecord::Migration
  def self.up
    create_table :woyongguos do |t|
      t.string :name
      t.string :logo
      t.string :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :woyongguos
  end
end
