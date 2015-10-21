namespace :mamashai do
  desc "update user groups."
  task :update_user_groups  => [:environment] do
    ActiveRecord::Base.transaction do
      User.all.each do |u|
        remarks=u.follow_users.all(:group=>'remark',:select=>'remark').collect{|fu| fu.remark}.compact
        remarks.each do |remark|
          fg=u.follows_groups.find_or_create_by_name(remark)
          u.follow_users.all(:conditions=>["remark=?",remark]).each do |fu|
            puts "import user #{u.email} remark #{remark} follows #{fu.follow_user_id}"
            fu.follows_group_id=fg.id
            fu.save
          end
          
          FollowsGroup.update_all("users_count=(select count(*) from follow_users where follows_group_id=#{fg.id})","id=#{fg.id} ")
        end
        
        
        fans_remarks=u.fans_users.all(:group=>'fans_remark',:select=>'fans_remark').collect{|fu| fu.fans_remark}.compact
        fans_remarks.each do |remark|
          fg=u.fans_groups.find_or_create_by_name(remark)
          u.fans_users.all(:conditions=>["fans_remark=?",remark]).each do |fu|
            puts "import user #{u.email} fans remark #{remark} fans #{fu.user_id}"
            fu.fans_group_id=fg.id
            fu.save
          end
          
          FansGroup.update_all("users_count=(select count(*) from follow_users where fans_group_id=#{fg.id})","id=#{fg.id}")
        end
        
        ####  recount user_kids age
        first_kid = u.first_kid
        if first_kid
          u.age_id = Age.get_age_id_from_birthday(first_kid.birthday)
          u.save
        end
        
      end
    end
  end
end
