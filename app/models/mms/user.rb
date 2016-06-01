class Mms::User < ActiveRecord::Base
  self.table_name = 'mms_users'

  has_many :articles, :foreign_key => :mms_user_id, :dependent => :delete_all
  has_and_belongs_to_many :menus, :class_name=>"Mms::Menu"
  
#  def before_create
#    self.password = Mms::User.encrypt(self.password)
#  end
  
  def self.check_login_user(username, password)
    user = Mms::User.find_by_username(username)
    if user
      if user.is_valid_password(password)
        return user
      end
    end
    false
  end
  
  def is_valid_password(password)
    self.password == Mms::User.encrypt(password)
  end
  
  def self.encrypt(password)
    MamashaiTools::TextUtil.md5(password)
  end
  
  def self.check_user(user)
    Mms::User.find(:first,:conditions=>["username=?",user.email]) 
  end
  
  def copy_columns_from_users(user)
    self.username = user.email
    self.password = user.password
    self
  end
  
  def self.find_user(mms_user)
    ::User.find_by_email(mms_user.username)
  end
  
end
