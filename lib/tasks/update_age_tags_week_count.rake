require 'rmmseg'
include RMMSeg

namespace :mamashai do
  desc "update age_tags_week_count. per 1 week "
  task :update_age_tags_week_count  => [:environment] do
    puts "开始更新……#{Time.new.to_s(:db)}"
    total_num = 0
    for tag in WeekTag.find(:all)
      week_count = Post.count(:conditions => ["created_at between ? and ? and match(content) against (? in boolean mode)", Time.new.ago(30.days), Time.new, tag.short_tag_name])
      total_count = Post.count(:conditions => ["match(content) against (? in boolean mode)", RMMSeg.segment(tag.short_tag_name).collect{|t| "+" + t}.join(' ')])
      tag.week_count = week_count
      tag.total_count = total_count
      tag.save
      puts "week tag #{tag.short_tag_name} : #{week_count} #{total_count}"
    end

    Age.all.each do |age|
      AgeTag.all(:conditions => ["tp = ?", 0], :order=>"id desc").each do |age_tag|
          next if !age_tag.short_tag_name || age_tag.short_tag_name == ""
          week_count = Post.count(:conditions => ["created_at between ? and ? and content like ?", Time.new.ago(30.days), Time.new, "%##{age_tag.short_tag_name}#%"])
          total_count = Post.count(:conditions => ["content like ?", "%##{age_tag.short_tag_name}#%"])
          #age_tag.update_attribute(:week_count,week_count)
          Post.connection.execute("update age_tags set week_count = #{week_count}, total_count= #{total_count} where id=#{age_tag.id}")
          #age_tag.week_count = week_count
          #age_tag.total_count = total_count
          #age_tag.save
          total_num = total_num + 1
          puts "id:#{age_tag.id} 话题为:#{age_tag.short_tag_name} 的标签共被讨论#{total_count}/#{week_count}次！"
      end
    end
    puts "更新完成！总共查询#{total_num}次 #{Time.new.to_s(:db)}"
    puts "查询时间段为#{last_week[0]}至#{last_week[1]}"
  end

  def date_en(time)
    time.strftime("%Y-%m-%d") if time
  end

  def last_week
    today = Time.now
    last_week_today = today - 7.day
    last_week_first = last_week_today -((last_week_today.wday) -1).day
    last_week_last = last_week_today + (7 - (last_week_today.wday)).day
    return date_en(last_week_first), date_en(last_week_last)
  end
end

