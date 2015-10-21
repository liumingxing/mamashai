module LmrbHelper
  def detail_age_for_birthday1(birthday, today=Date.today)
    return '出生' if birthday.today?
    return '出生' if birthday.year == today.year && birthday.month == today.month && birthday.day == today.day
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        
        str = ""
        str << "孕" if today < birthday
        str << "#{months}个月" if months > 0
        str << "#{days}天" if days > 0
      end
    end
    str
  end 
  
  def detail_age_for_birthday2(birthday, today=Date.today)
    return '出生' if birthday.today?
    return '出生' if birthday.year == today.year && birthday.month == today.month && birthday.day == today.day
    str = ''
    motn_days = {1=>31,2=>28,3=>31,4=>30,5=>31,6=>30,7=>31,8=>31,9=>30,10=>31,11=>30,12=>31}
    if birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day
      if today >= birthday 
        if days < 0
          months -=1
          days = motn_days[today.month] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        
        str = ""
        str << "#{years}岁" if years > 0
      end
    end
    str
  end 
end
