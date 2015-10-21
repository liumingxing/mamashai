class AddColumnSendIntervalToMmsEmails < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :send_interval, :integer, :default => 1 # => 每次发送时间间隔
    add_column :mms_emails, :ignore_email_type, :string # => 不发送的邮箱类型
  end

  def self.down
    remove_column :mms_emails, :send_interval
    remove_column :mms_emails, :ignore_email_type
  end
end
