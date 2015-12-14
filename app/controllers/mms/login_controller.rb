class Mms::LoginController < Mms::MmsBackEndController

  skip_before_filter :check_mms_user_login, only: [:login, :chklogin]
  
  def index
    redirect_to :action => 'login'
  end
  
  def login
  end
  
  def chklogin
    current_user = Mms::User.check_login_user(params[:username], params[:password])
    if current_user
      session[:mms_user_id] = current_user.id
      session[:mms_user] = current_user.username
      redirect_to :action => 'main'
    else
      redirect_to :action => 'login'
    end
  end
  
  def main
    @roots = Mms::Menu.find(:all, :order=>"position", :conditions=>"parent_id is null or parent_id=''")
    session[:pid] = params[:id]
    render :layout=>false
  end
  
  def logout
    session[:mms_user_id] = nil
    session[:mms_user] = nil
    redirect_to :action => 'login'
  end
  
  def my
    @user = @mms_user
  end
end
