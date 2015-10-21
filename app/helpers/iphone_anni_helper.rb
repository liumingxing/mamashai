module IphoneAnniHelper
  def make_note(text)
    "<a href='javascript:void(0)' onclick=\"make_note('#{text}')\"><img src='/iphone_anni/images/s.jpg'/></a>"
  end
end
