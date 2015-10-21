namespace :mamashai do
  desc "send emails to users on settime"
  task :send_emails  => [:environment] do
    emails = Mms::Email.find(:all, :conditions => "state = 'wait' or state = 'send'")
    for email in emails
      email.sending
      ActionMailer::Base.delivery_method = :sendmail
      ActionMailer::Base.delivery_method = :smtp if email.email_server_type == "2"
      if email.send_time <= Time.now
        i = 0   # => 记录正在发送的邮件数
        j = 0   # => 记录邮件对应文件从哪一行开始发送
        line_numbers = email.line_numbers||1    # => 记录发送到邮件对应文件的哪一行
        File.open(email.file_path) do |file|
          file.each{|line|
            j += 1
            email.reload
            break unless email.state == "send"
            next unless i < email.send_count
            next unless j == line_numbers
            line_numbers += 1
            email.update_attribute(:line_numbers, line_numbers)
            i += 1
            if i == email.send_count
              i = 0
              sleep(email.send_interval * 60)
            end
            email_address = line.rstrip
            next if email_address.blank?
            (puts "#{email_address} <邮件未发送>"; next) if email.ignore_email_type.present? and email_address =~ /#{email.ignore_email_type}/
            puts "邮件发送方式：#{ActionMailer::Base.delivery_method}"
            mail_body = Mailer.create_send_user_html_email(email, email_address)
            mail_result = "#{email_address} <邮件发送失败>"
            mail_result = "#{email_address} <邮件发送成功>" if Mailer.deliver_email(mail_body) 
            puts "#{mail_result}"
          }
        end
        email.finish if j == email.line_numbers - 1
      end
    end
  end
end