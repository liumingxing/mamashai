# -*- coding: utf-8 -*-
class Mailer < ActionMailer::Base
  helper :application
  default :from => "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"

  
  def send_signup(user_signup)
    user_profile = UserProfile.find_by_user_id(user_signup.id)
    @subject    = "#{APP_CONFIG['email_signup_title']}"
    @user_signup = user_signup
    @user_profile = user_profile
    @recipients = user_signup.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {}

    mail :to=>@recipients, :subject=>@subject
  end
  
  def find_password(user)
    @subject    = "#{APP_CONFIG['email_password_title']}"
    @user       = user
    @recipients = user.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {}

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_invite(user,invite_code)
    @subject    = "#{APP_CONFIG['email_invite_title_pre']}#{user.name}#{APP_CONFIG['email_invite_title_post']}"
    @user       = user
    @invite_code = invite_code
    @recipients = invite_code.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_book_invite(baby_book,baby_book_user,user,email)
    @subject    = "#{user.name}在妈妈晒推荐你去看#{baby_book_user.name}的宝贝图书！"
    @user       = user
    @baby_book  = baby_book
    @baby_book_user = baby_book_user
    @recipients = email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_holiday(email)
    @subject    = "父亲节到了，妈妈晒网站现在开始免费赠送“宝贝姓名贴”" 
    @recipients = email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_html_holiday(user)
    @subject    = "妈妈晒宝贝图书大赛精彩推荐"
    @user       = user
    @recipients = user.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_html_match(user)
    @subject    = "六一给孩子特别的礼物，自己制作《宝贝图书》，还能赢取世博会亲子游"
    @user       = user
    @recipients = user.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
 
  def notify_message(user)
    @subject    = "#{APP_CONFIG['email_notify_message_title']}"
    @user       = user
    @recipients = user.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def notify_gift(user)
    @subject    = "#{APP_CONFIG['email_notify_gift_title']}"
    @user       = user
    @recipients = user.email
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {} 

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_user_email(email, email_address)
    @subject    = email.subject
    @body       = email.content
    @recipients = [email_address]
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {}

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_user_html_email(email, email_address)
    @subject    = email.subject
    @body       = email.content
    @recipients = ["#{email_address}"]
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    @sent_on    = Time.now
    @headers    = {}

    mail :to=>@recipients, :subject=>@subject
  end

  def send_survey_email(email)
    subject     "50本育儿电子书免费下载"
    recipients  email
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com>"
    body :email=>email
    sent_on     Time.now
    headers     {}    

    mail :to=>@recipients, :subject=>@subject
  end

  def send_another_survey_email(email)
    subject     "50本育儿完全宝典免费下载"
    recipients  email
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    body :email=>email
    sent_on     Time.now
    headers     {}    

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_order_new(order_id,tuan)
    @tuan = tuan
    supplier_code = @tuan.supplier_code
    @supplier = Supplier.last(:conditions=>["code=?",supplier_code])
    @item = OrderItem.last(:conditions=>["order_id=? and item_id=?",order_id,@tuan.id])
    @order = @item.order
    
    if @supplier
      subject     "妈妈晒供应商订单信息提醒：有用户下了新的订单(未付款)"
      recipients  @supplier.email
      from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
      sent_on     Time.now
      headers     {}   
      content_type "text/html"
    end

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_order_payup(order_id,tuan)
    @tuan = tuan
    supplier_code = @tuan.supplier_code
    @supplier = Supplier.last(:conditions=>["code=?",supplier_code])
    
    if @supplier
      @item = OrderItem.last(:conditions=>["order_id=? and item_id=?",order_id,@tuan.id])
      @order = @item.order
      @log = OrderLog.last(:conditions => ["log = ? and order_id=?", "订单已支付",@order.id])
      subject     "妈妈晒供应商订单信息提醒：有用户支付了订单(已付款)"
      recipients  @supplier.email
      from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
      sent_on     Time.now
      headers     {}   
      content_type "text/html"
    end

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_order_user_new(order)
    @order = order
    @user = @order.user
    subject     "妈妈晒订单信息提醒：您在妈妈晒下了订单，但没有付款"
    recipients  @user.email
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    sent_on     Time.now
    headers     {}   
    content_type "text/html"

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_order_user_payup(order)
    @order = order
    @user = @order.user
    subject     "妈妈晒订单信息提醒：您在妈妈晒支付了订单"
    recipients  @user.email
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    sent_on     Time.now
    headers     {}   
    content_type "text/html"

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_product_email(user_emails,message)
    @message = message
    subject     "妈妈晒商品发放系统"
    recipients  user_emails
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    sent_on     Time.now
    headers     {}   

    mail :to=>@recipients, :subject=>@subject
  end
  
  def send_bafu_email(bafu_form)
  	@subject    = "有人提交了八福公学的报名表"
    @recipients = "tracy@mamashai.com"
    @from       = "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    @sent_on    = Time.now
    @headers    = {}   
    @form       = bafu_form
    @content_type = "text/html"

    mail :to=>@recipients, :subject=>@subject
  end
   
  def quan_email(user_email,quan)
    @quan = quan
    @product = @quan.virtual_product
    @order = @quan.order_item.order
    subject     "妈妈晒商品发放系统"
    recipients  user_email
    from        "\"#{APP_CONFIG['email_mamashai']}\" <mail@mamashai.com.cn>"
    sent_on     Time.now
    headers     {} 
    content_type "text/html"

    mail :to=>@recipients, :subject=>@subject
  end
  
  
  ###################### begin general methods ##########################  

  
  def self.deliver_email(mail)
    mail.content_transfer_encoding = '7bit'
    #mail.set_content_type("text/html") 
    mail.charset = 'UTF-8' 
    mail.deliver
  end
  ###################### end general methods ##########################   
  
end
