class CreateBabyBookLayouts < ActiveRecord::Migration
  def self.up
    create_table :baby_book_layouts do |t|
      t.string :name
      t.text :html
      t.text :css
      t.text :html_sandbox
      t.text :html_history
      t.text :css_sandbox
      t.text :css_history
      t.integer :is_publish
      t.integer :lock_version
      t.integer :tp,:default=>1
      t.timestamps
    end
  end

  def self.down
    drop_table :baby_book_layouts
  end
end
