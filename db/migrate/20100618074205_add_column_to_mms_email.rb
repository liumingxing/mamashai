class AddColumnToMmsEmail < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :send_count, :integer # => 一次发送邮件人数
  end

  def self.down
    remove_column :mms_emails, :send_count
  end
end
