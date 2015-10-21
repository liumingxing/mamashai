class CreateTuanMessages < ActiveRecord::Migration
  def self.up
    create_table :tuan_messages do |t|
      t.string :content, :null => false
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :tuan_messages
  end
end
