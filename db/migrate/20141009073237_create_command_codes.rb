class CreateCommandCodes < ActiveRecord::Migration
  def change
    create_table :command_codes do |t|
      t.string :code
      t.string :status
      t.string :result
      t.datetime :after
      t.timestamps
    end
  end
end
