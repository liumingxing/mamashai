class Supplier < ActiveRecord::Base
  validates_presence_of(:code, :message => "编号不能为空")
  validates_presence_of(:name, :message => "名称不能为空")
  validates_presence_of(:password, :message => "密码不能为空")
  validates_presence_of(:address, :message => "地址不能为空")
  validates_presence_of(:phone, :message => "电话不能为空")
  validates_presence_of(:mobile, :message => "手机不能为空")
  validates_numericality_of(:mobile, :message => "手机号码只能为数字")
  validates_presence_of(:email, :message => "Email　不能为空")
  validates_presence_of(:contacter, :message => "联系人不能为空")  
end
