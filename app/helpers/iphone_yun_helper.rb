module IphoneYunHelper
  def title(name)
    name.gsub(/_\d+/, "").gsub(/\d+$/, '').upcase
  end
  
  def make_note(text)
    "<a href='javascript:void(0)' onclick=\"make_note('#{text}')\"><img src='/iphone_yun/images/s.gif'/></a>"
  end
  
  def make_note_center(text)
    "<div style='text-align: center'><a href='javascript:void(0)' onclick=\"make_note('#{text}')\"><img src='/iphone_yun/images/s.gif'/></a></div>"
  end
end
