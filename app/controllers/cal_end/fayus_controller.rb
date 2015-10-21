include CalEnd

class CalEnd::FayusController < ApplicationController
  layout "cal_end"
  
  def index
    list
    render :action => 'list'
  end

  def list
    @fayus = Fayu.paginate :page=>params[:page], :per_page => 36, :order=>"id"
  end

  def show
    @fayu = Fayu.find(params[:id])
  end

  def new
    @fayu = Fayu.new
  end

  def create
    @fayu = Fayu.new(params[:fayu])
    if @fayu.save
      flash[:notice] = 'Fayu was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @fayu = Fayu.find(params[:id])
  end

  def update
    @fayu = Fayu.find(params[:id])
    if @fayu.update_attributes(params[:fayu])
      flash[:notice] = 'Fayu was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Fayu.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
