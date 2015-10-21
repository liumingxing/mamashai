class CreateZhuantis < ActiveRecord::Migration
  def self.up
#    create_table :zhuantis do |t|
#      t.string :name
#      t.string :logo
#      t.text   :introduct
#      t.string :url
#      t.datetime :begin_at
#      t.timestamps
#    end
  end

  def self.down
    drop_table :zhuantis
  end
end
