class CreateMmsEmails < ActiveRecord::Migration
  def self.up
    create_table :mms_emails do |t|
      t.string :subject   # => 邮件主题
      t.text :content   # => 邮件内容
      t.datetime :send_time # => 邮件发送时间
      t.integer :seccessed_account  # => 发送成功数
      t.integer :failed_account   # => 发送失败数
      t.string :state   # => 邮件发送状态
      t.string :flag    # => 标志发送用户，所有用户，营销人员，注册用户
      t.string :file_path   # => 存放邮件地址、发送状态, 1:未发送，2：已发送，3：发送成功，4：发送失败

      t.timestamps
    end
  end

  def self.down
    drop_table :mms_emails
  end
end
