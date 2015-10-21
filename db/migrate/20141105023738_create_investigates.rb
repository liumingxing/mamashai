class CreateInvestigates < ActiveRecord::Migration
  def change
    create_table :investigates do |t|
      t.integer :user_id
      t.integer :tp
      t.string :ip
      t.string  :s1
      t.string  :s2
      t.string  :s3
      t.string  :s4
      t.string  :s5
      t.string  :s6
      t.string  :s7
      t.string  :s8
      t.string  :s9
      t.string  :s10
      t.string  :s11
      t.string  :s12
      t.string  :s13
      t.string  :s14
      t.string  :s15
      t.string  :s16
      t.string  :s17
      t.string  :s18
      t.string  :s19
      t.string  :s20
      t.string  :s21
      t.string  :s22
      t.string  :s23
      t.string  :s24
      t.string  :s25
      t.string  :s26
      t.string  :s27
      t.string  :s28
      t.timestamps
    end
  end
end
