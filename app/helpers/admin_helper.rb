# Methods added to this helper will be available to all templates in the application.
module AdminHelper
  
  def true_or_false(is_true)
    if is_true
      '<img src="/images/icons/icons_01.png" />'
    else
      '<img src="/images/icons/icon_25.gif" />'
    end
  end
  
  def search_user_box
    render :partial=>"search_user_box"
  end

  
end
