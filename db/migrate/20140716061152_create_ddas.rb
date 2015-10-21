class CreateDdas < ActiveRecord::Migration
  def change
    create_table :ddas do |t|
      t.string :mobile
      t.string :network
      t.string :city
    end
  end
end
