namespace :mamashai do
  desc "推送送宝宝日历宝典"
  task :refresh_ddh_status  => [:environment] do
    ddhs = Ddh.all
    for ddh in ddhs
      ddh.set_status
      ddh.save
    end
  end
end
