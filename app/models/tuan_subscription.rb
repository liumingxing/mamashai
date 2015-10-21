class TuanSubscription < ActiveRecord::Base
  validates_presence_of :email, :message => "邮件地址不能为空"
  validates_uniqueness_of :email, :message => "该邮件地址已存在"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "请正确输入邮件地址" 
end
