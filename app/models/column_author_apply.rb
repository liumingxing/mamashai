class ColumnAuthorApply < ActiveRecord::Base
  belongs_to :user
  upload_column :logo #,:process => '1024x1024', :versions => {:thumb120 => "90x120", :thumb400 => "300x400" }
  validates_presence_of :real_name,:message=>"真实姓名不能为空"
  validates_presence_of :identity_type,:message=>"证件类型不能为空"
  validates_presence_of :identity_id,:message=>"证件号码不能为空"
  validates_presence_of :mobile,:message=>"移动电话不能为空"
  validates_format_of :mobile, :with => /^((13[0-9])|(18[0,5-9])|(15[0-3,5-9]))\d{8}$/, :message=>"移动电话格式不正确"
  validates_presence_of :email,:message=>APP_CONFIG['error_signup_email']
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message=>APP_CONFIG['error_signup_email_wrong']
  validates_presence_of :plan_describe,:message=>"不能为空"

  def show_gender
    gender = {"w" => APP_CONFIG['gender_label_w'], "m" => APP_CONFIG['gender_label_m']}
    gender[self.gender]
  end
end
