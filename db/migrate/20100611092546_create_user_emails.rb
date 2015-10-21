class CreateUserEmails < ActiveRecord::Migration
  def self.up
    create_table :user_emails do |t|
      t.string :email
    end
  end

  def self.down
     drop_table :user_emails
  end
end
