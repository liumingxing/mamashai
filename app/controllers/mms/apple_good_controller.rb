class Mms::AppleGoodController < Mms::MmsBackEndController
	def index
    list
    render :action => 'list'
  end

  def list
    @apple_goods = AppleGood.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def show
    @apple_good = AppleGood.find(params[:id])
  end

  def new
    @apple_good = AppleGood.new
  end

  def create
    @apple_good = AppleGood.new(params[:apple_good])
    if @apple_good.save
      flash[:notice] = '添加成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @apple_good = AppleGood.find(params[:id])
  end

  def update
    @apple_good = AppleGood.find(params[:id])
    if @apple_good.update_attributes(params[:apple_good])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    AppleGood.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
