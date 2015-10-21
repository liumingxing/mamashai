class CalEnd::Month < CalEnd::Base
  def distance_human
    if distance < 0
      "孕#{10+distance}月"
    else
      "#{distance/12}岁#{distance % 12}月"
    end
  end

  #传入生日，获得distance
  def self.functions(birthday, today=Date.today)
	distance = 0
    if birthday <= today					#已出生
    	year  = today.year - birthday.year
    	month = today.month - birthday.month
    	date  = today.day - birthday.day
    	if month < 0
    		year -= 1
    		month += 12
    	end

    	if (date < 0)
    		month -= 1
    		date += 30
    	end

    	if date >= 28
    		date = 27
    	end
    	distance = year*48 + month*4 + (date/7)
    else										# 未出生
    	days_diff = (today - birthday).to_i
    	distance = days_diff/7
    	if (days_diff%7).abs > 0
    		distance -= 1
    	end
    end
    
    month = CalEnd::Month.find_by_distance(distance)
    functions =  month ? month.functions : ""
    return distance, functions
  end
end
