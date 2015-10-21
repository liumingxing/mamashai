class CreateColumnAuthorApplies < ActiveRecord::Migration
  def self.up
    create_table :column_author_applies do |t|
      t.integer :user_id
      t.string :real_name
      t.string :gender
      t.string :identity_type
      t.string :identity_id
      t.string :tel
      t.string :mobile
      t.string :blog
      t.string :weibo
      t.string :qq
      t.string :email
      t.text :plan_describe
      t.string :logo


      t.timestamps
    end
  end

  def self.down
    drop_table :column_author_applies
  end
end
