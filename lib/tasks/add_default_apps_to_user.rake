namespace :mamashai do
  desc "add default apps to user"
  task :add_default_apps_user  => [:environment] do
    ActiveRecord::Base.transaction do 
      for user in User.find(:all) 
        Mms::App.add_default_apps(user)     
      end
    end
    puts "add user default app is fine "
  end
end
