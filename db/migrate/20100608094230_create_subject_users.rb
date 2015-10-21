class CreateSubjectUsers < ActiveRecord::Migration
  def self.up
    create_table :subject_users do |t|
      t.integer :subject_id
      t.integer :user_id
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :subject_users
  end
end
