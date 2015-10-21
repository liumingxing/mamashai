class Mms::BseAppliesController < Mms::MmsBackEndController
  skip_before_filter :check_mms_user_login
  skip_before_filter :check_mms_user_power

  def index
    list
    render :action => 'list'
  end

  def list
    @bse_applies = BseApply.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def show
    @bse_apply = BseApply.find(params[:id])
  end

  def new
    @bse_apply = BseApply.new
  end

  def create
    @bse_apply = BseApply.new(params[:bse_apply])
    if @bse_apply.save
      flash[:notice] = 'BseApply was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bse_apply = BseApply.find(params[:id])
  end

  def update
    @bse_apply = BseApply.find(params[:id])
    if @bse_apply.update_attributes(params[:bse_apply])
      flash[:notice] = 'BseApply was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    BseApply.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
