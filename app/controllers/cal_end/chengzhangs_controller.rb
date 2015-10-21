include CalEnd

class CalEnd::ChengzhangsController < ApplicationController
  layout "cal_end"
  
  def index
    list
    render :action => 'list'
  end

  def list
    @chengzhangs = Chengzhang.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @chengzhang = Chengzhang.find(params[:id])
  end

  def new
    @chengzhang = Chengzhang.new
  end

  def create
    @chengzhang = Chengzhang.new(params[:chengzhang])
    if @chengzhang.save
      flash[:notice] = 'Chengzhang was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @chengzhang = Chengzhang.find(params[:id])
  end

  def update
    @chengzhang = Chengzhang.find(params[:id])
    if @chengzhang.update_attributes(params[:chengzhang])
      flash[:notice] = 'Chengzhang was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Chengzhang.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
