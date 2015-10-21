namespace :mamashai do
  desc "补上空头像"
  task :add_default_logo  => [:environment] do
    #补上头像
    p Time.new
    users = User.all(:order => "id desc", :limit=>500)
    for u in users
    	if !u.logo
    		u.add_default_logo
      		u.save
    	end
    end
    p Time.new
    
    #users = User.all(:conditions=>"logo is null and created_at > '#{Time.new.ago(2.hours).to_s(:db)}'")
    #for u in users
    #  u.add_default_logo
    #  u.save
    #end
  end
end
