class CreateAcategories < ActiveRecord::Migration
  def change
    create_table :acategories do |t|
      t.string :name
      t.string :logo
      t.timestamps
    end
  end
end
