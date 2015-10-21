class Mms::KeywordSignupController < Mms::MmsBackEndController
  
  def index 
    @keyword_signups = KeywordSignup.paginate(:per_page => 20,:page => params[:page], :order => "id DESC")
  end
  
  def new
    
  end
  
  def create
    if KeywordSignup.create(params[:keyword_signup]).errors.blank?
      flash[:notice] = "新建广告统计成功！"
      redirect_to :action => :index
    else
      flash[:notice] = "新建广告统计失败！"
      redirect_to :back
    end
  end
  
  def edit
    @keyword_signup = KeywordSignup.find(params[:id])
  end
  
  def update
    keyword_signup = KeywordSignup.find(params[:id])
    if keyword_signup.update_attributes(params[:keyword_signup])
      flash[:notice] = "修改广告统计成功！"
      redirect_to :action => :index
    else
      flash[:notice] = "修改广告统计失败！"
      redirect_to :back
    end
  end
  
  def update_hits_count
    keyword_signup = KeywordSignup.find(params[:id])
    flash[:notice] = "#{keyword_signup.name}：点击次数清０成功！"
    flash[:notice] = "#{keyword_signup.name}：点击次数清０失败！" unless keyword_signup.update_attribute(:hits_count, 0)
    redirect_to :action => :index
  end
  
  def update_signups_count
    keyword_signup = KeywordSignup.find(params[:id])
    flash[:notice] = "#{keyword_signup.name}：注册用户数清０成功！"
    flash[:notice] = "#{keyword_signup.name}：注册用户数清０失败！" unless keyword_signup.update_attribute(:signups_count, 0)
    redirect_to :action => :index
  end
  
  def destroy
    flash[:notice] = "删除广告统计成功！"
    flash[:notice] = "删除广告统计失败！" unless KeywordSignup.find(params[:id]).destroy
    redirect_to :action => :index
  end
  
end
