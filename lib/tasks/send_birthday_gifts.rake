namespace :mamashai do
  desc "判断宝宝生日，并送礼物"
  task :send_birthday_gifts  => [:environment] do
    User.update_all "level_score = level_score + 1", "last_login_at > '#{Time.new.ago(24.hours).to_s(:db)}'"
    LevelScoreLog.create(:score=>0, :total_score=>-1, :desc=>"每天增加经验分")
    
    offset = 0;
    today = Date.today
    kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday < '#{today.to_s(:db)}' and birthday like '%#{today.to_s(:db)[5,5]}'")
    offset += 1000
    while kids.size > 0
      for kid in kids
        next if !kid.user
        p "#{kid.id} #{kid.name} #{kid.birthday}"
        gift = GiftGet.create_user_gift_gets(kid.user, {:gift_get=>{:gift_id=>125, :user_id=>431, :send_user_id=>kid.user.id, :is_no_name=>0, :is_private=>0, :is_send_hide=>0, :is_get_hide=>0, :content=>"今天是#{kid.name||'宝宝'}的生日，送个蛋糕，祝快乐成长哦！"}})
        
        gift.save

        if ScoreEvent.count(:conditions=>"event = 'baby_birthday' and user_id = #{kid.user.id} and created_at > '#{Time.new.ago(30.days).to_s(:db)}'") == 0
          Mms::Score.trigger_event(:baby_birthday, "宝宝生日送晒豆", 2, 1, {:user => kid.user})
        end
      end
      kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday < '#{today.to_s(:db)}' and birthday like '%#{today.to_s(:db)[5,5]}'")
      offset += 1000
    end

    #满月
    offset = 0
    kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday = '#{Time.new.ago(30.days).to_date.to_s}'")
    while kids.size > 0
      for kid in kids
        next if !kid.user
        p "#{kid.id} #{kid.name} #{kid.birthday}"
        gift = GiftGet.create_user_gift_gets(kid.user, {:gift_get=>{:gift_id=>73, :user_id=>431, :send_user_id=>kid.user.id, :is_no_name=>0, :is_private=>0, :is_send_hide=>0, :is_get_hide=>0, :content=>"亲，恭喜宝宝满月啦！送您一束粉色玫瑰，愿妈妈宝宝每天健康好心情！"}})
        
        gift.save

        if ScoreEvent.count(:conditions=>"event = 'baby_month' and user_id = #{kid.user.id} and created_at > '#{Time.new.ago(30.days).to_s(:db)}'") == 0
          Mms::Score.trigger_event(:baby_month, "宝宝满月送晒豆", 2, 1, {:user => kid.user})
        end
      end
      kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday = '#{Time.new.ago(30.days).to_date.to_s}'")
      offset += 1000
    end

    #百天
    offset = 0
    kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday = '#{Time.new.ago(100.days).to_date.to_s}'")
    while kids.size > 0
      for kid in kids
        next if !kid.user
        p "#{kid.id} #{kid.name} #{kid.birthday}"
        gift = GiftGet.create_user_gift_gets(kid.user, {:gift_get=>{:gift_id=>111, :user_id=>431, :send_user_id=>kid.user.id, :is_no_name=>0, :is_private=>0, :is_send_hide=>0, :is_get_hide=>0, :content=>"亲，恭喜宝宝百天啦！送个小熊玩具，祝宝宝天天健壮，幸福快乐！"}})
        
        gift.save

        if ScoreEvent.count(:conditions=>"event = 'baby_100day' and user_id = #{kid.user.id} and created_at > '#{Time.new.ago(30.days).to_s(:db)}'") == 0
          Mms::Score.trigger_event(:baby_100day, "宝宝百天送晒豆", 2, 1, {:user => kid.user})
        end
      end
      kids = UserKid.find(:all, :order=>"id", :limit=>1000, :offset=>offset, :conditions=>"birthday = '#{Time.new.ago(100.days).to_date.to_s}'")
      offset += 1000
    end
  end
end