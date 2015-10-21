namespace :mamashai do
  desc "执行命令队列2"
  task :execute_command_code  => [:environment] do
    puts "开始执行"
    while 1
      begin
        codes = CommandCode.find(:all, :conditions=>"status='wait' and after<'#{Time.new.to_s(:db)}'", :limit=>20, :order=>"id asc")
        for code in codes
          p code.id
          begin
            code.result = eval(code.code)
          rescue
          end
          code.status = 'finished'
          code.save
        end
      rescue
      end
      sleep(3)
    end
  end
end
