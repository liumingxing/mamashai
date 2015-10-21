include CalEnd

class CalEnd::WeeksController < ApplicationController
  layout "cal_end"
  
  def index
    list
    render :action => 'list'
  end

  def list
    @weeks = Weeks.paginate :page=>params[:page], :per_page => 10, :order=>"id"
  end

  def show
    @weeks = Weeks.find(params[:id])
  end

  def new
    @weeks = Weeks.new
  end

  def create
    @weeks = Weeks.new(params[:weeks])
    if @weeks.save
      flash[:notice] = 'Weeks was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @weeks = Weeks.find(params[:id])
  end

  def update
    @weeks = Weeks.find(params[:id])
    if @weeks.update_attributes(params[:weeks])
      flash[:notice] = 'Weeks was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Weeks.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
