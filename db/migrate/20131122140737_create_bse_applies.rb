class CreateBseApplies < ActiveRecord::Migration
  def self.up
    create_table :bse_applies do |t|
      t.integer :user_id
      t.string :name
      t.string :mobile
      t.string :age
      t.timestamps
    end
  end

  def self.down
    drop_table :bse_applies
  end
end
