class CreateMbookPages < ActiveRecord::Migration
  def self.up
    create_table :mbook_pages do |t|
      t.integer :user_id
      t.string :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :mbook_pages
  end
end
