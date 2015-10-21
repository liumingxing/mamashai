require 'mamashai_tools/taobao_util'
require 'open-uri'
include MamashaiTools

namespace :mamashai do
  desc "获取宝宝日历VIP"
  task :get_bbrl_stars  => [:environment] do
    
    Tongji.delete_all("created_at < '#{Time.new.ago(2.days).to_s(:db)}'")
    CommandQueue.delete_all("created_at < '#{Time.new.ago(2.days).to_s(:db)}'")
    CommandCode.delete_all("created_at < '#{Time.new.ago(2.days).to_s(:db)}'")

    ids = Blockstar.all.collect{|c| c.user_id}.join(",")

    max = BbrlStar.first(:select=>"max(num) as n")
    num = max['n'].to_i + 1

    ddhs = Ddh.all
    for ddh in ddhs
      ddh.set_status
      ddh.save
    end

    now = Time.new
    today = now.ago(2.days).to_date           #算过去两天的数据统计
    users = User.find_by_sql("select users.*, count(comments.id) from users left join comments on users.id = comments.post_user_id where users.id not in (#{ids}) and comments.created_at > '#{today.to_s}' and users.posts_count > 10 and comments.user_id <> users.id group by users.id order by count(comments.id) desc limit 84;")
    count = 0
    #宝宝日历之星
    BbrlVip.delete_all
    
    for user in users
      break if count >= 4
      next if user.name == "妈妈晒"
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 20, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"bbrl", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1

      vip = BbrlVip.new
      vip.user_id = user.id
      vip.user_name = user.name
      vip.save
      user.add_level_score(10, "进入星星榜")
    end

    #新秀之星
    count = 0
    users = User.find_by_sql("select users.*, count(comments.id) from users left join comments on users.id = comments.post_user_id where users.id not in (#{ids}) and comments.created_at > '#{today.to_s}' and users.posts_count < 10 and comments.user_id <> users.id group by users.id order by users.posts_count*2 + count(comments.id) desc limit 84;")
    for user in users
      break if count >= 4
      
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 20, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"rookie", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1     
      user.add_level_score(10, "进入星星榜")
    end

    #图片之星
    count = 0
    users = User.find_by_sql("select users.* from posts left join users on users.id = posts.user_id where users.id not in (#{ids}) and posts.is_hide = 0 and posts.is_private=0 and posts.logo is not null and posts.created_at > '#{today.to_s}' and (posts.`from` is null or posts.`from` <> 'caiyi' and posts.`from` <> 'bbyulu'  and posts.`from` <> 'biaoqing' and posts.`from` <> 'shijian') group by users.id order by count(posts.id) desc limit 84;")
    for user in users
      break if count >= 4
      next if user.name == "妈妈晒"
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 20, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"tupian", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1     
      user.add_level_score(10, "进入星星榜")
    end

    #满月之星
    count = 0
    users = User.find_by_sql("select users.* from user_kids left join users on users.id = user_kids.user_id left join posts on posts.id = users.last_post_id where posts.is_hide = 0 and posts.is_hide = 0 and posts.is_private = 0 and posts.created_at > '#{now.ago(30.days).to_s(:db)}' and users.id not in (#{ids}) and user_kids.birthday = '#{now.months_since(-1).to_date.to_s}' and users.last_login_at > '#{now.ago(30.days).to_s(:db)}' and users.first_kid_id = user_kids.id and user_kids.logo is not null order by users.posts_count desc limit 10;")
    for user in users
      break if count >= 4
      next if user.name == "妈妈晒"
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 7, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"birth_30", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1
      user.add_level_score(10, "进入星星榜")
    end

    #百天之星
    count = 0
    users = User.find_by_sql("select users.* from user_kids left join users on users.id = user_kids.user_id left join posts on posts.id = users.last_post_id where posts.is_hide = 0 and posts.is_hide = 0 and posts.is_private = 0 and  posts.created_at > '#{now.ago(30.days).to_s(:db)}' and users.id not in (#{ids}) and user_kids.birthday = '#{now.ago(100.days).to_date.to_s}' and users.last_login_at > '#{now.ago(30.days).to_s(:db)}' and users.first_kid_id = user_kids.id and user_kids.logo is not null order by users.posts_count desc limit 10;")
    for user in users
      break if count >= 4
      next if user.name == "妈妈晒"
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 7, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"birth_100", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1
      user.add_level_score(10, "进入星星榜")
    end

    #周岁之星
    count = 0
    users = User.find_by_sql("select users.* from user_kids left join users on users.id = user_kids.user_id left join posts on posts.id = users.last_post_id where posts.is_hide = 0 and posts.is_hide = 0 and posts.is_private = 0 and  posts.created_at > '#{now.ago(30.days).to_s(:db)}' and users.id not in (#{ids}) and user_kids.birthday = '#{now.years_since(-1).to_date.to_s}' and users.last_login_at > '#{now.ago(30.days).to_s(:db)}' and users.first_kid_id = user_kids.id and user_kids.logo is not null order by users.posts_count desc limit 10;")
    if users.size < 4
	users = User.find_by_sql("select users.* from user_kids left join users on users.id = user_kids.user_id left join posts on posts.id = users.last_post_id where posts.is_hide = 0 and posts.is_hide = 0 and posts.is_private = 0 and users.id not in (#{ids}) and user_kids.birthday = '#{now.years_since(-1).to_date.to_s}' and users.last_login_at > '#{now.ago(30.days).to_s(:db)}' and users.first_kid_id = user_kids.id and user_kids.logo is not null order by users.posts_count desc limit 10;")
    end

    for user in users
      break if count >= 4
      next if user.name == "妈妈晒"
      next if BbrlStar.count(:conditions=>["num > ? and user_id = ?", num - 7, user.id]) > 0   #一周内当选过
      BbrlStar.create(:tp=>"birth_365", :user_id=>user.id, :num=>num)
      Mms::Score.trigger_event(:xxb, "进入星星榜", 10, 1, {:user => user})
      count += 1
      user.add_level_score(10, "进入星星榜")
    end
  end
end
