namespace :mamashai do
  desc "send survey emails to users"
  task :send_survey_emails  => [:environment] do
#      ActionMailer::Base.delivery_method = :smtp
      File.open File.join(RAILS_ROOT,"tmp","email.txt"),"r" do |f|
        i=0
	f.each_line do |line|
	   mail=Mailer.create_send_survey_email(line)
	   Mailer.deliver_email(mail)
	   puts line 
	   if i == 10
	     puts "sleep"
             sleep(60)
 	     i = 0
	   end
	   i+=1
	end
      end
  end
end
