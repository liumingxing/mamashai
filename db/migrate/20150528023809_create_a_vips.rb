class CreateAVips < ActiveRecord::Migration
  def change
    create_table :a_vips do |t|
      t.string :code
      t.float  :value, :default=>1000
      t.float  :used, :default=>0
      t.timestamps
    end
  end
end
