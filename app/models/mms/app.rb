class Mms::App < ActiveRecord::Base
  self.table_name = "mms_apps"
  has_many :user_apps, :foreign_key => "mms_app_id", :dependent => :destroy
  has_many :users, :through => :user_apps
  
  validates_presence_of :logo, :on => :save, :message => "logo不能为空"
  validates_presence_of :url, :on => :save, :message => "URL不能为空"
  validates_presence_of :name, :on => :save, :message => "组件名称不能为空"
  validates_presence_of :content, :on => :save, :message => "功能描述不能为空"
  validates_presence_of :icon, :on => :save, :message => "图片不能为空"
  validates_presence_of :tp, :message => "类型不能为空"
  
  APP_TYPES = [[0,'记录类组件'],[1,'互动类组件'],[2,'其他类']]
  
  def self.get_types
    APP_TYPES.collect{|type| type.reverse}
  end
  
  def get_type
    APP_TYPES.select{|type| type[0]==self.tp}[0][1]
  end
  
  def self.add_default_apps(user)
    return if UserApp.all(:conditions=>{:user_id => user.id}).present? 
    ActiveRecord::Base.transaction do 
      mms_apps = Mms::App.find(:all, :conditions => {:is_default => true})
      for app in mms_apps
        UserApp.create(:user_id => user.id, :mms_app_id => app.id, :position => app.default_position)
      end
    end
  end
  
  def is_new_add
    create_time = self.created_at
    return create_time >= Date.today-14    
  end
end
