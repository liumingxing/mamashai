class CreatePks < ActiveRecord::Migration
  def change
    create_table :pks do |t|
      t.integer :num
      t.string :title
      t.date :start_date
      t.date :end_date
      t.date :result_date
      t.string :reward
      t.string :participate_desc
      t.integer :max_select
      t.string :select_list
      t.string :photo_desc
      t.references :calendar_adv
      t.timestamps
    end
  end
end
