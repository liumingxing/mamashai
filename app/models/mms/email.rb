require 'state_machine'
class Mms::Email < ActiveRecord::Base
  self.table_name = "mms_emails"
  validates_presence_of :subject, :on => :save, :message => "邮件主题不能为空"
  #validates_presence_of :content, :on => :save, :message => "邮件内空不能为空"
  validates_presence_of :send_time, :on => :save, :message => "邮件发送时间不能为空"
  #validates_presence_of :send_count, :on => :save, :message => "邮件发送人数不能为空"
  #validates_numericality_of :send_count, :on => :save, :greater_than_or_equal_to => 0, :message => "邮件发送人数必须大于等于0"
  validates_presence_of :flag, :on => :save, :message => "收件人不能为空"
  validates_presence_of :email_server_type, :on => :save, :message => "邮件服务器类型不能为空"
  
  state_machine :initial => :draft do
    state :wait
    state :send
    state :stop
    state :pause
    state :finish
    
    event :sending do
      transition :draft => :wait
      transition :finish => :wait
      transition :stop => :wait
      transition :pause => :send
      transition :wait => :send
    end
    
    event :pause do
      transition :wait => :pause
      transition :send => :pause
    end
    
    event :stop do
      transition :wait => :stop
      transition :send => :stop
      transition :pause => :stop
    end
    
    event :finish do
      transition :send => :finish
    end
    
  end
  
  def create_email(email)
    self.tuan_id = email[:tuan_id]
    self.url = email[:url]
    unless email[:picture].blank? or email[:tuan_id].blank?
      FileUtils.rm_r(File.join(RAILS_ROOT, "/public/email/tuan_#{self.tuan_id}")) if File.exists?(File.join(RAILS_ROOT, "/public/email/tuan_#{self.tuan_id}"))
      picture = email[:picture]
      picture_type = picture.content_type.chomp.split("/")
      picture_root_path = File.join(RAILS_ROOT, 'public', 'email', "tuan_#{self.tuan_id}")
      FileUtils.mkdir_p(picture_root_path) unless File.exists?(picture_root_path)
      FileUtils.cp("#{picture.path}", File.join(picture_root_path, "picture.#{picture_type[picture_type.length - 1]}"))
      self.picture = "/email/tuan_#{self.tuan_id}/picture.#{picture_type[picture_type.length - 1]}" if File.exists?(picture_root_path)
      self.images_path = MamashaiTools::ImageUtil.update_tuan_email_picture(self, picture_root_path, 200, picture_type[picture_type.length - 1]) unless self.picture.blank?
    end
    self.send_time = DateTime::civil(email['send_time(1i)'].to_i, email['send_time(2i)'].to_i, email['send_time(3i)'].to_i, email['send_time(4i)'].to_i, email['send_time(5i)'].to_i)
    self.send_count = email[:send_count]
    self.subject = email[:subject]
    self.content = email[:content]
    self.test_address = email[:test_address].downcase
    self.flag = email[:flag]
    self.send_interval = email[:send_interval]
    self.ignore_email_type = email[:ignore_email_type]
    self.email_server_type = email[:email_server_type]
    if self.save and self.file_path.blank?
      unless File.directory? File.join(RAILS_ROOT,"email")
        Dir.mkdir("#{RAILS_ROOT}/email")
      end
      File.open(File.join(RAILS_ROOT,"email","tmp_#{self.id}.txt"),"w") do |file|
        if self.flag == "所有用户"
          user_emails = ActiveRecord::Base::UserEmail.find(:all)
          for user in user_emails
            file.puts("#{user.email.downcase}")
          end
          users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
          for user in users
            file.puts("#{user.email.downcase}")
          end
        elsif self.flag == "营销人员"
          user_emails = ActiveRecord::Base::UserEmail.find(:all)
          for user in user_emails
            file.puts("#{user.email.downcase}")
          end
        elsif self.flag == "注册用户"
          users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
          for user in users
            file.puts("#{user.email.downcase}")
          end
        else
          
        end
      end
      self.file_path = "#{RAILS_ROOT}/email/tmp_#{self.id}.txt"
      unless self.save
        return self.errors
      end
    else
      return self.errors
    end
  end
  
  def show_address
    all_users = []
    if self.flag == "所有用户"
      user_emails = ActiveRecord::Base::UserEmail.find(:all)
      unless user_emails.blank?
        all_users = user_emails
      end
      users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
      unless users.blank?
        all_users += users
      end
    elsif self.flag == "营销人员"
      user_emails = ActiveRecord::Base::UserEmail.find(:all)
      unless user_emails.blank?
        all_users = user_emails
      end
    elsif self.flag == "注册用户"
      users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
      unless users.blank?
        all_users = users
      end
    else
      
    end
    return all_users
  end
  
  def update_address(flag)
    unless File.directory? File.join(RAILS_ROOT,"email")
      Dir.mkdir("#{RAILS_ROOT}/email")
    end
    File.open(File.join(RAILS_ROOT,"email","tmp_#{self.id}.txt"),"w") do |file|
      if flag == "所有用户"
        user_emails = ActiveRecord::Base::UserEmail.find(:all)
        for user in user_emails
          file.puts("#{user.email.downcase}")
        end
        users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
        for user in users
          file.puts("#{user.email.downcase}")
        end
      elsif flag == "营销人员"
        user_emails = ActiveRecord::Base::UserEmail.find(:all)
        for user in user_emails
          file.puts("#{user.email.downcase}")
        end
      elsif flag == "注册用户"
        users = ActiveRecord::Base::User.find(:all, :conditions => "tp >= 0")
        for user in users
          file.puts("#{user.email.downcase}")
        end
      else
        
      end
    end
    self.flag = flag
    self.file_path = "#{RAILS_ROOT}/email/tmp_#{self.id}.txt"
    unless self.save
      return self.errors
    end
  end
  
  def update_email(email)
    self.tuan_id = email[:tuan_id]
    self.url = email[:url]
    unless email[:picture].blank? or email[:tuan_id].blank?
      FileUtils.rm_r(File.join(RAILS_ROOT, "/public/email/tuan_#{self.tuan_id}")) if File.exists?(File.join(RAILS_ROOT, "/public/email/tuan_#{self.tuan_id}"))
      picture = email[:picture]
      picture_type = picture.content_type.chomp.split("/")
      picture_root_path = File.join(RAILS_ROOT, 'public', 'email', "tuan_#{self.tuan_id}")
      FileUtils.mkdir_p(picture_root_path) unless File.exists?(picture_root_path)
      FileUtils.cp("#{picture.path}", File.join(picture_root_path, "picture.#{picture_type[picture_type.length - 1]}"))
      self.picture = "/email/tuan_#{self.tuan_id}/picture.#{picture_type[picture_type.length - 1]}" if File.exists?(picture_root_path)
      self.images_path = MamashaiTools::ImageUtil.update_tuan_email_picture(self, picture_root_path, 200, picture_type[picture_type.length - 1]) unless self.picture.blank?
    end
    self.send_time = DateTime::civil(email['send_time(1i)'].to_i, email['send_time(2i)'].to_i, email['send_time(3i)'].to_i, email['send_time(4i)'].to_i, email['send_time(5i)'].to_i)
    self.send_count = email[:send_count]
    self.subject = email[:subject]
    self.content = email[:content]
    self.test_address = email[:test_address]
    self.send_interval = email[:send_interval]
    self.ignore_email_type = email[:ignore_email_type]
    self.email_server_type = email[:email_server_type]
    unless self.save
      return self.errors
    end
  end
  
  def delete_email
    tuan_id = self.tuan_id
    if self.destroy
      FileUtils.rm("#{self.file_path}")
      FileUtils.rm_r(File.join(RAILS_ROOT, "/public/email/tuan_#{tuan_id}")) if File.exists?(File.join(RAILS_ROOT, "/public/email/tuan_#{tuan_id}"))
    else
      return self.errors
    end
  end
  
  def sent_email
    if self.state == "finish"
      self.line_numbers = 1
    end
    self.sending
    unless self.save
      return self.errors
    end
  end
  
  def send_email_now # => 测试发送邮件
    email_address = ""
    test_addresses = self.test_address.split(";")
    unless test_addresses.blank?
      for test_address in test_addresses
        if email_address.blank?
          email_address = '"'+"#{test_address}"+'"'
        else
          email_address += ', "'+"#{test_address}"+'"'
        end
      end
    end
    unless email_address.blank?
      if Mailer.deliver_email(Mailer.send_user_email(self, email_address))
        return "发送邮件成功！"
      else
        return "发送邮件失败！"
      end
    end
  end
  
end
