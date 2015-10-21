class CreateAlogos < ActiveRecord::Migration
  def change
    create_table :alogos do |t|
      t.integer :aproduct_id
      t.string :path
      t.timestamps
    end
  end
end
