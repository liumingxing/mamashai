namespace :mamashai do
  desc "提醒一周内没有记录的用户来记录"
  task :remind_user_to_write  => [:environment] do
    offset = 0
    users = User.all(:limit=>1000, :offset=>offset, :conditions=>"last_login_at < '#{Time.new.ago(7.days).to_s(:db)}'", :order=>"id asc")
    while users.size > 0
    	for user in users
            next if !user.first_kid

    		kid_name = user.user_kids.map{|k| k.name}.join('、')||"宝宝"
    		reminds = ["亲，好久没来，妈妈晒的朋友们想#{kid_name}了！", 
    					"亲，过去这段时间#{kid_name}成长一定有精彩的瞬间，来记录一下吧！",
    					"今天记录#{kid_name}的成长，明天回忆起来满满都是幸福，来看看其他妈妈都记了什么吧！",
    					"亲，你没来的这段日子里，妈妈晒有好多好玩的记录，来看看吧！",
    					"亲，好久没来了，一定很忙吧，来看看妈妈晒的好玩记录，开心一下吧！",
    					"亲，有段日子没见了，#{kid_name}一定又长大了吧，来记录一下吧"]

    		p "#{user.id} #{kid_name} #{reminds[rand(reminds.size)]}"
    		MamashaiTools::ToolUtil.push_aps(user.id, reminds[rand(reminds.size)])
    	end
    	offset += 1000
    	users = User.all(:limit=>1000, :offset=>offset, :conditions=>"last_login_at < '#{Time.new.ago(7.days).to_s(:db)}'", :order=>"id asc")
    end
  end
end
