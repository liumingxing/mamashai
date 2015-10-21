# Methods added to this helper will be available to all templates in the application.
module HomeHelper
  
  def home_nav_count_str(count)
    "<span class='orange'>(#{count})</span>" if count > 0
  end
  
  
  def info_checkbox
    info_users_id=APP_CONFIG['info_users_id']
    # return check_box(:post, :tp, :checked=>true )+APP_CONFIG['info_check_box'] if info_users_id.include?(@user.id)
    # return check_box(:post, :tp, {}, "2","0" )+APP_CONFIG['info_check_box'] if @user.is_org?
    return check_box(:post, :tp, :checked=>true )+APP_CONFIG['info_check_box'] if info_users_id.include?(@user.id) or @user.is_org?
  end
  
  def info_users
    info_users_id=APP_CONFIG['info_users_id']
    html=""
    info_users=User.find(info_users_id)
    info_users.each do |u|
      html << "<li><a href='/pub/info_posts?u_id=#{u.id}'> #{u.name} </a></li>"
    end
    return html
  end
end
