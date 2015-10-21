require 'score'

namespace :mamashai do
  desc "积分清70%"
  task :clear_score  => [:environment] do
    puts "开始清零"
    #offset = 0
    #users = User.find(:all, :order=>"id", :offset=>offset, :limit=>2000)
    #while users.size > 0
    # 	for user in users
    #		p user.id
    #		if user.score > 4
	#   		Mms::Score.trigger_event(:clear_score, "积分清零", 1, 1, {:user => user, :cost=>0-user.score*0.7,:description=>"每年7月积分清掉70%"})
	#    	end
    #	end
    #	offset += 2000
    #	users = User.find(:all, :order=>"id", :offset=>offset, :limit=>2000)
    #end

    offset = 0
    events = ScoreEvent.find(:all, :order=>"id", :conditions=>"event = 'clear_score'", :limit=>2000, :offset=>offset)
    while events.size > 0
    	for event in events
    		user = User.find(event.user_id)
    		user.score += event.score
    		user.save
    		p user.id
    	end
    	offset += 2000
    	events = ScoreEvent.find(:all, :order=>"id", :conditions=>"event = 'clear_score'", :limit=>2000, :offset=>offset)
    end
  end
end