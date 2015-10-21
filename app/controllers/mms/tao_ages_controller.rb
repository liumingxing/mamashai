class Mms::TaoAgesController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @ages = TaoAge.all
  end

  def edit
    @tao_age = TaoAge.find(params[:id])
  end

  def update
    @age = TaoAge.find(params[:id])
    if @age.update_attributes(params[:tao_age])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
end
