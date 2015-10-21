class Mms::ColumnAuthorApplyManageController < Mms::MmsBackEndController
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    @column_author_applys = ColumnAuthorApply.paginate(:per_page => 20, :page => page, :order => "id desc")
  end

  def edit

  end

  def destroy
    flash[:notice] = "删除成功"
    column_author_apply = ColumnAuthorApply.find_by_id(params[:id])
    flash[:notice] = "删除失败" unless column_author_apply.destroy
    redirect_to :action => :index
  end

  def find
    page = (params[:page] unless params[:page].blank?) || 1
    if params[:search][:title].blank?
      redirect_to :action => :index
      return
    end
    @column_author_applys = ColumnAuthorApply.paginate(:per_page => 20, :page =>page, :conditions=>["real_name like ?","%#{params[:search][:title]}%"], :order => "id DESC")
    render :action => :index
  end

  def create_column_author
    user = ::User.find_by_id(params[:user_id])
    if user
      if ColumnAuthor.find_by_user_id(user.id)
        flash[:notice] = "这个用户已经是专栏作者了"
      else
        ColumnAuthor.create(:user_id => user.id)
        flash[:notice] = "操作成功！ [#{user.name}] 被设置为专栏作者"
      end
    else
      flash[:notice] = "找不到这个用户"
      redirect_to :action=> :index
      return
    end
    redirect_to :action=>  :index
  end

end