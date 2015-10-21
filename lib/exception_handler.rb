module ExceptionHandler
  
  protected

  def record_not_found
     logger.error("404 displayed")   
      render(:file  => "#{::Rails.root.to_s}/public/404.html",   
        :status   => "404 Not Found") and return false
  end

  def template_not_found
     logger.error("404 displayed")   
      render(:file  => "#{::Rails.root.to_s}/public/404.html",   
        :status   => "404 Not Found") and return false
  end
  
  def action_not_found
     logger.error("404 displayed")  
     puts  "action_not_found"
      render(:file  => "#{::Rails.root.to_s}/public/404.html",   
        :status   => "404 Not Found")  and return false 
  end
  
  def foreign_key_existed
    logger.error("foreign_key_existed")  
    puts  "foreign_key_existed"
    render(:file  => "#{::Rails.root.to_s}/public/404.html",   
        :status   => "404 Not Found") and return false
  end
  
  def common_error
    logger.error("common_exception_occur")  
    puts  "common_exception_occur"
    render(:file  => "#{::Rails.root.to_s}/public/500.html",   
        :status   => "500 error") and return false
  end
  
end