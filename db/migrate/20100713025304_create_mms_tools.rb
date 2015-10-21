class CreateMmsTools < ActiveRecord::Migration
  def self.up
    create_table :mms_tools do |t|
      t.string :name
      t.text :content
      t.integer :users_count, :default=>0
      t.string :logo
      t.string :pdf
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mms_tools
  end
end
