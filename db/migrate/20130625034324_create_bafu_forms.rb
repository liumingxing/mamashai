class CreateBafuForms < ActiveRecord::Migration
  def self.up
    create_table :bafu_forms do |t|
	  t.string :name
	  t.string :name2
	  t.string :name3
	  t.date :birthday
	  t.string :parent_name
	  t.string :mobile
	  t.string :kind
	  t.string :desc
	  t.string :born_at
	  t.string :email
	  t.string :target
      t.timestamps
    end
  end

  def self.down
    drop_table :bafu_forms
  end
end
