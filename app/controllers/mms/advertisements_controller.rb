class Mms::AdvertisementsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @advertisements = Advertisement.paginate :page=>params[:page], :per_page => 50, :order=>"id desc"
  end

  def show
    @advertisement = Advertisement.find(params[:id])
  end

  def new
    @advertisement = Advertisement.new
  end

  def create
    @advertisement = Advertisement.new(params[:advertisement])
    if @advertisement.save
      flash[:notice] = 'Advertisement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @advertisement = Advertisement.find(params[:id])
  end

  def update
    @advertisement = Advertisement.find(params[:id])
    if @advertisement.update_attributes(params[:advertisement])
      flash[:notice] = 'Advertisement was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Advertisement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
