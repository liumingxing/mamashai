class Mms::AdvertisementLogosController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @advertisement = Advertisement.find(params[:id])
    @advertisement_logos = AdvertisementLogo.paginate :page=>params[:page], :per_page => 10, :conditions=>"advertisement_id = #{params[:id]}",  :order=>"id desc"
  end

  def show
    @advertisement_logo = AdvertisementLogo.find(params[:id])
  end

  def new
    @advertisement = Advertisement.find(params[:id])
    @advertisement_logo = AdvertisementLogo.new
  end

  def create
    @advertisement_logo = AdvertisementLogo.new(params[:advertisement_logo])
    @advertisement_logo.advertisement_id = params[:id]
    if @advertisement_logo.save
      flash[:notice] = '上传成功'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @advertisement_logo = AdvertisementLogo.find(params[:id])
  end

  def update
    @advertisement_logo = AdvertisementLogo.find(params[:id])
    @advertisement_logo.logo = params[:advertisement_logo][:logo] if params[:advertisement_logo][:logo]
    @advertisement_logo.save
    logger.info @advertisement_logo.errors
    if @advertisement_logo.update_attributes(params[:advertisement_logo])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list', :id=>@advertisement_logo.advertisement_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    AdvertisementLogo.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
