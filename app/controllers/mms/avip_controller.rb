class Mms::AvipController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @vips = AVip.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"  
  end

  def new
    @vip = AVip.new
  end

  def create
    @vip = AVip.new(params[:vip])
    if @vip.save
      flash[:notice] = '创建成功'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @vip = AVip.find(params[:id])
  end

  def update
    @vip = AVip.find(params[:id])
    @vip.save
    logger.info @vip.errors
    if @vip.update_attributes(params[:vip])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list', :id=>@vip.advertisement_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    AVip.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
