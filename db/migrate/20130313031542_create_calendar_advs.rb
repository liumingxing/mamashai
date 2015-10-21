class CreateCalendarAdvs < ActiveRecord::Migration
  def self.up
    create_table :calendar_advs do |t|
      t.string :name
      t.string :logo
      t.integer :tp	#1:blank url 2:app url 3:code
      t.text :code
      t.string :status, :default=>'online'
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_advs
  end
end
