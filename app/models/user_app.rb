class UserApp < ActiveRecord::Base
  belongs_to :user, :class_name => "ActiveRecord::Base::User"
  belongs_to :mms_app, :class_name => "Mms::App",:counter_cache => true
  validates_presence_of :user_id, :on => :save, :message => "用户不能为空"
  validates_presence_of :mms_app_id, :on => :save, :message => "组件不能为空"
end
