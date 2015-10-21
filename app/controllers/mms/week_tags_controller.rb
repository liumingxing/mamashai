class Mms::WeekTagsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @week_tags = WeekTag.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @week_tag = WeekTag.find(params[:id])
  end

  def new
    @week_tag = WeekTag.new
  end

  def create
    @week_tag = WeekTag.new(params[:week_tag])
    if @week_tag.save
      flash[:notice] = '新建热点话题成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @week_tag = WeekTag.find(params[:id])
  end

  def update
    @week_tag = WeekTag.find(params[:id])
    if @week_tag.update_attributes(params[:week_tag])
      flash[:notice] = '修改热点话题成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    WeekTag.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def make_current
    WeekTag.update_all("current = 0")
    week_tag = WeekTag.find(params[:id])
    week_tag.current = true
    week_tag.save

    Rails.cache.delete("half_screen_advs_ios")
    Rails.cache.delete("half_screen_advs_android")

    redirect_to :action=>"list"
  end
end
