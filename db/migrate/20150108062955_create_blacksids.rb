class CreateBlacksids < ActiveRecord::Migration
  def change
    create_table :blacksids do |t|
      t.string :sid
      t.timestamps
    end
  end
end
