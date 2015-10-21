require 'score'

namespace :mamashai do
  desc "执行命令队列"
  task :execute_command_queue  => [:environment] do
    puts "开始执行"
    #while 1
    #    commands = CommandQueue.find(:all, :conditions=>"status='wait'", :limit=>10, :order=>"id")
    #    for command in commands
    #        result = `#{command.command}`
    #        command.status = 'finished'
    #        command.result = result
    #        command.save
    #        p command.id
    #    end
    #    sleep(1)
    #end

    while 1
      commands = CommandQueue.find(:all, :conditions=>"status='wait' and try_times < 10 and created_at < '#{Time.new.to_s(:db)}'", :limit=>20, :order=>"id desc")
      threads = []
      for command in commands
          threads << Thread.new(command) do |c|
            p c.command
	          begin
              c.result = `#{c.command.gsub("\n", "")}`[0,200]
              c.try_times += 1
              if c.result.to_s.size > 0 && c.result.to_s.index('{') == 0
                c.status = 'finished' 
              end
  	          c.save
            rescue
            end
            p c.result
            p c.id
          end
      end
      threads.each{|th| th.join(10)}
      sleep(3)
    end


    #1.upto(10) do |i|
    #  Thread.new do 
    #    while 1
    #      synchronize do
    #        commands = CommandQueue.find(:all, :conditions=>"status='wait'", :order=>"id", :limit=>6)
    #        for command in commands
    #          command.status = "finished"
    #          command.save
    #        end
    #      end
    #      for command in commands
    #        command.result = `#{command.command}`
    #        command.save
    #      end
    #    end
    #  end
    #end
  end
end
