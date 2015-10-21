class AddColumnTestAddressToMmsEmails < ActiveRecord::Migration
  def self.up
    add_column :mms_emails, :test_address, :text # => 测试邮件地址
  end

  def self.down
    remove_column :mms_emails, :test_address
  end
end
