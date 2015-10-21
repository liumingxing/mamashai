class AppGender < ActiveRecord::Base
  def self.tick(tp)
    first = AppGender.find(:first)
    if !first
      first = AppGender.new
    end
    first.qing += 1 if tp == 'qing'
    first.fuqi += 1 if tp == "fuqi"
    first.titai += 1 if tp == "titai"
    first.save
  end
  
  def self.tick_of(tp)
    first = AppGender.find(:first)
    return 0 if !first
    return first.qing if tp == "qing"
    return first.fuqi if tp == "fuqi"
    return first.titai if tp == "titai"
    return 1001
  end
end
