class AddColumnEmailServerTypeToMmsEmails < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :email_server_type, :string, :limit => 1, :default => 1   # => 1:sendmail, 2:SMTP
  end

  def self.down
    remove_column :mms_emails, :email_server_type
  end
end
