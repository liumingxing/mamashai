namespace :mamashai do
  desc "给空头像者随机加头像."
  task :add_logo  => [:environment] do
    for user in User.find(:all, :conditions=>"logo is null")
      if user.gender == 'w'
        file = File.open("public/images/login/logo/#{1+rand(25)}.jpg", 'rb')
        user.logo = file
      else
        file = File.open("public/images/login/logo/#{27 + rand(22)}.jpg", 'rb')
        user.logo = file
      end
      p user.id
      user.save_with_validation(false)
      file.close
    end
  end
end
