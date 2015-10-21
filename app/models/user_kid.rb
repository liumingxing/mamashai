class UserKid < ActiveRecord::Base 
  belongs_to :user,:counter_cache => true
  
 # validates_presence_of :name,:message=>APP_CONFIG['error_user_kid_name']
 # validates_presence_of :gender,:message=>APP_CONFIG['error_user_kid_gender']
  validates_presence_of :user_id
  
  after_save :update_user_age_id
  
  before_save :get_star
  before_save :get_month
  
  #upload_column :logo,:process => '450x450', :versions => { :thumb140 => 'c140x140', :thumb75 => "c75x75",:thumb30 => "c30x30"}
  upload_column :logo,:process => '450x450', :versions => { :thumb140 => 'c140x140', :thumb75 => "c75x75",:thumb30 => "c30x30"}, :store_dir=>proc{|kid, file| "user_kid/#{kid.created_at.strftime("%Y-%m-%d")}/#{kid.id}/logo"}
  
  after_create :push_notify
  after_create :upload_to_aliyun

  def push_notify
    if self.birthday > Time.new.to_date   #怀孕
      MamashaiTools::ToolUtil.push_aps(self.user_id, "亲，快快来记录孕育#{self.name||'宝宝'}时的感受吧！")
    else
      MamashaiTools::ToolUtil.push_aps(self.user_id, "亲，快快来记录#{self.name}成长的精彩瞬间吧！")
    end
  end

  def upload_to_aliyun
    return if !self.logo
    return if !File.exist?(self.logo.path)

    begin
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb140.filename}", File.open(self.logo.thumb140.path), {:content_type => self.logo.thumb140.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb75.filename}", File.open(self.logo.thumb75.path), {:content_type => self.logo.thumb75.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb30.filename}", File.open(self.logo.thumb30.path), {:content_type => self.logo.thumb30.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    rescue
      sleep(1)
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.filename}", File.open(self.logo.path), {:content_type => self.logo.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb140.filename}", File.open(self.logo.thumb140.path), {:content_type => self.logo.thumb140.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb75.filename}", File.open(self.logo.thumb75.path), {:content_type => self.logo.thumb75.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/user_kid/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo/#{self.logo.thumb30.filename}", File.open(self.logo.thumb30.path), {:content_type => self.logo.thumb30.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    end
  end

  #得出月份
  def get_month
    if self.birthday
      self.month = "%4d%02d" % [self.birthday.year, self.birthday.month]
    end
  end

  #计算星座
  def get_star
    return if !self.birthday
    month = self.birthday.month
    mday = self.birthday.mday

    birth = "%02d-" % month + "%02d" % mday

    if birth >= "03-21" && birth<= "04-20"
      self.star = 1
    elsif birth >= "04-21" && birth<= "05-21"
      self.star = 2
    elsif birth >= "05-22" && birth<= "06-21"
      self.star = 3
    elsif birth >= "06-22" && birth<= "07-23"
      self.star = 4
    elsif birth >= "07-24" && birth<= "08-23"
      self.star = 5
    elsif birth >= "08-24" && birth<= "09-23"
      self.star = 6
    elsif birth >= "09-24" && birth<= "10-23"
      self.star = 7
    elsif birth >= "10-24" && birth<= "11-22"
      self.star = 8
    elsif birth >= "11-23" && birth<= "12-22"
      self.star = 9
    elsif birth >= "12-23" || birth<= "01-22"
      self.star = 10
    elsif birth >= "01-21" && birth<= "02-19"
      self.star = 11
    elsif birth >= "02-20" && birth<= "03-20"
      self.star = 12
    end
  end

  def update_user_age_id
    return if !self.user
    user.first_kid_id = self.id if !self.user.first_kid
    Age.update_user_age_id(self.user)
  end
  
  ##################### attributes ##########################
  
  def is_signuped
    !(self.birthday.blank? && self.gender.blank? && self.name.blank?)
  end
  
  def name_str
    self.name.blank?  ?  APP_CONFIG['no_kid_name'] : self.name
  end
  
  
  ###################### update ##################
  
  def update_user_kid_star 
    if self.birthday
      self.star = Age.get_kid_star_from_birthday(self.birthday)
      self.save
    end
  end
  
  def update_user_kid(params)
    begin
      self.update_attributes(params)
    rescue
      self.errors.add(:tp,APP_CONFIG['error_time_format']) 
    end
    self.update_user_kid_star
  end
  
  def save_user_kid(user)
    return unless self.errors.empty?
    self.user_id = user.id
    self.star = Age.get_kid_star_from_birthday(self.birthday) if self.birthday
    self.save 
  end
  
  
  ################## create #################
  
  def self.create_user_kids_from_signup(user_signup,user)
    return if user_signup.blank? or user_signup.kids_count.blank?
    ActiveRecord::Base.transaction do
      age_ids = []
      if user_signup.kids_count == 0
        user_kid0 = UserKid.create_user_kid_without_validation(user_signup.kid_birthday4,user)
        age_ids << Age.get_age_id_from_birthday(user_signup.kid_birthday4)
      end
      if user_signup.kids_count >= 1
        user_kid1 = UserKid.create_user_kid_without_validation(user_signup.kid_birthday1,user,user_signup.kid_gender1)
        age_ids << Age.get_age_id_from_birthday(user_signup.kid_birthday1)
      end
      if user_signup.kids_count >= 2
        UserKid.create_user_kid_without_validation(user_signup.kid_birthday2,user,user_signup.kid_gender2)
        age_ids << Age.get_age_id_from_birthday(user_signup.kid_birthday2)
      end
      if user_signup.kids_count == 3
        UserKid.create_user_kid_without_validation(user_signup.kid_birthday3,user,user_signup.kid_gender3)
        age_ids << Age.get_age_id_from_birthday(user_signup.kid_birthday3)
      end
      user.age_ids = age_ids.sort.join(',') 
      user.first_kid = user_kid0 if user_kid0
      user.first_kid = user_kid1 if user_kid1
      user.first_kid = user_kid1 if user_kid1
      user.save_without_validation
      Age.update_user_age_id(user) 
    end 
  end 
  
  
  def self.create_user_kid_without_validation(birthday,user,gender=nil)
    user_kid = UserKid.new(:birthday=>birthday,:user_id=>user.id,:gender=>gender)
    user_kid.star = Age.get_kid_star_from_birthday(birthday)
    user_kid.save_without_validation
    user_kid
  end
  
  def self.update_user_kids(user,params)
    success = true
    user_kids = user.user_kids
    begin
      user_kid1 = UserKid.new(params[:user_kid1])
    rescue
      user_kid1 = UserKid.new
      user_kid1.errors.add(:tp,APP_CONFIG['error_time_format']) 
    end
    begin
      user_kid2 = UserKid.new(params[:user_kid2])
    rescue
      user_kid2 = UserKid.new
      user_kid2.errors.add(:tp,APP_CONFIG['error_time_format']) 
    end
    begin
      user_kid3 = UserKid.new
      user_kid3 = UserKid.new(params[:user_kid3])
    rescue
      user_kid3.errors.add(:tp,APP_CONFIG['error_time_format']) 
    end
    
    ActiveRecord::Base.transaction do
      if user_kid1.is_signuped
        if user_kids.length >= 1
          user_kid1 = user_kids[0] 
          user_kid1.update_user_kid(params[:user_kid1])
        else 
          user_kid1.save_user_kid(user)
        end
        unless user_kid1.errors.empty?
          success = false
        end
      end
      if user_kid2.is_signuped
        if user_kids.length >= 2
          user_kid2 = user_kids[1]
          user_kid2.update_user_kid(params[:user_kid2])
        else
          user_kid2.save_user_kid(user)
        end
        unless user_kid2.errors.empty?
          success = false
        end
      end
      if user_kid3.is_signuped
        if user_kids.length >= 3
          user_kid3 = user_kids[2]
          user_kid3.update_user_kid(params[:user_kid3])
        else
          user_kid3.save_user_kid(user)
        end
        unless user_kid3.errors.empty?
          success = false
        end
      end
      if user_kid1 and user_kid1.birthday and user_kid1.errors.empty?
        user.first_kid = user_kid1
        age_ids = []
        age_ids = user.age_ids.split(',') unless user.age_ids.blank? 
        age_ids = age_ids.concat(user.user_kids.collect{|kid| Age.get_age_id_from_birthday(kid.birthday).to_s}).uniq!
        user.age_ids = age_ids.sort.join(',') unless age_ids.blank? 
        user.save
        Age.update_user_age_id(user) 
      end
    end
    
    return success,user_kid1,user_kid2,user_kid3
  end
  
  ############## find ###############
  
  def self.find_index_user_kids
    UserKid.find(:all,:limit=>32,:conditions=>['user_kids.logo is not null'],:include=>[:user],:order=>'user_kids.id desc')
  end
  
  
  def age(detail=false)
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if self.birthday
      today = Date.today
      if today < self.birthday 
        pregnant_day = self.birthday - 280 
        self.birthday = pregnant_day if pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        if pregnant_day
          str = "#{APP_CONFIG['have_baby']}#{months}#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        else
          if detail
            str = "#{years}#{APP_CONFIG['age']}#{months}#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
          else
            str = "#{years}#{APP_CONFIG['age']}"
          end
        end
      end
    end
    str
  end
  
  
  def kid_age
    today, birthday = Date.today, self.birthday
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if birthday.present?
      #today = Date.today
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        if pregnant_day
          str = "#{APP_CONFIG['have_baby']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        else
          str = "#{years}#{APP_CONFIG['age']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        end
      end
    end
    str
  end 
  
  def logo_url_thumb140
    logo.try(:thumb140).try(:url)
  end
  
  def logo_url_thumb75
    logo.try(:thumb75).try(:url)
  end
  
  def logo_url_thumb30
    logo.try(:thumb30).try(:url)
  end
  
  def logo_url
    logo.try(:url)
  end
  
  # ==json_methods 输出方法
  # * id: id
  # * name: 姓名
  # * gender: 性别
  # * education: 教育程度
  # * education_org: 教育机构
  def self.json_attrs
    %w{id name gender education education_org birthday content}
  end
  
  # ==json_methods 输出方法
  # * kid_age: 省份
  # * logo_url: 默认图片地址450x450
  # * logo_url_thumb30: 30x30 缩略图地址
  def self.json_methods
    %w{kid_age logo_url_thumb30 logo_url_thumb75 logo_url_thumb140 logo_url}
  end

  def as_json(options = {})
    options[:only] ||= UserKid.json_attrs
    options[:methods] ||= UserKid.json_methods
    super options
  end
  
end
