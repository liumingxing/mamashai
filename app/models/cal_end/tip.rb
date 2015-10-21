class CalEnd::Tip < CalEnd::Base
  def distance_human
    if distance < 0
      "孕#{40+distance}周"
    else
      month = distance / 4
      "#{month/12}岁#{month % 12}月#{distance % 4}周"
    end
  end
end
