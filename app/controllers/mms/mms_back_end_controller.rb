class Mms::MmsBackEndController < ApplicationController
  
  layout 'mms_admin'
    
  before_filter :check_mms_user_power, :except => ["login", "chklogin", "logout"]
  
  def check_mms_user_login
    if session[:mms_user].nil?
      redirect_to :controller => 'mms/login', :action => 'login'
    end
  end
  
  def check_mms_user_power
    @mms_user = Mms::User.find(session[:mms_user_id])
  end
  
end
