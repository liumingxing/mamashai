class CreateTaoAges < ActiveRecord::Migration
  def change
    create_table :tao_ages do |t|
      t.integer :month
      t.string  :desc
      t.timestamps
    end
  end
end
