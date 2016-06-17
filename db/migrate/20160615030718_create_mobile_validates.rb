class CreateMobileValidates < ActiveRecord::Migration
  def change
    create_table :mobile_validates do |t|
      t.string :mobile
      t.string :code
      t.boolean :checked, default: false

      t.timestamps
    end
  end
end
