class CreateApnLastPages < ActiveRecord::Migration
  def change
    create_table :apn_last_pages do |t|
      t.integer :tp
      t.string :page_url
      t.timestamps
    end
  end
end
