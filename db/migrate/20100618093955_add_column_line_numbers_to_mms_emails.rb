class AddColumnLineNumbersToMmsEmails < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :line_numbers, :integer # => 记录email对应文件发送到的行数
  end

  def self.down
    remove_column :mms_emails, :line_numbers
  end
end
