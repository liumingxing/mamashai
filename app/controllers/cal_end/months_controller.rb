include CalEnd

class CalEnd::MonthsController < ApplicationController
  layout "cal_end"
  
  skip_before_filter :verify_authenticity_token    
  def index
    list
    render :action => 'list'
  end

  def list
    @months = Month.paginate :page=>params[:page], :per_page => 10, :order=>"id"
  end

  def show
    @month = Month.find(params[:id])
  end

  def new
    @month = Month.new
  end

  def create
    @month = Month.new(params[:month])
    if @month.save
      flash[:notice] = '添加月份成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @month = Month.find(params[:id])
  end

  def update
    @month = Month.find(params[:id])
    @month.functions = params[:functions].join(',') if params[:functions]
    if @month.update_attributes(params[:month])
      flash[:notice] = '修改月份成功.'
      redirect_to :action => 'list', :page=>params[:page]
    else
      render :action => 'edit'
    end
  end

  def destroy
    Month.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
