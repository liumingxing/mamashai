class CreateBbrlReports < ActiveRecord::Migration
  def self.up
    create_table :bbrl_reports do |t|
      t.integer :user_id
      t.string :user_name
      t.string :q1
      t.string :q2
      t.string :q3
      t.string :q4
      t.string :q5
      t.string :q6
      t.string :q7
      t.string :q8
      t.string :q9
      t.string :q10
      t.string :q11
      t.string :q12
      t.string :q13
      t.string :q14
      t.string :q15
      t.string :q16
      t.timestamps
    end
  end

  def self.down
    drop_table :bbrl_reports
  end
end
