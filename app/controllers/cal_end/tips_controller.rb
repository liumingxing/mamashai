include CalEnd

class CalEnd::TipsController < ApplicationController
  layout "cal_end"
  
  #protect_from_forgery :only => [:index] 

  def index
    list
    render :action => 'list'
  end

  def list
    conditions = ["1=1"]
    conditions << "t='#{params[:t]}'" if params[:t]
    @tips = Tip.paginate :page=>params[:page], :per_page => 12, :order=>"distance", :conditions=>conditions.join(' and ')
  end

  def show
    @tip = Tip.find(params[:id])
  end

  def new
    @tip = Tip.new
  end

  def create
    @tip = Tip.new(params[:tip])
    if @tip.save
      flash[:notice] = '创建tip成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tip = Tip.find(params[:id])
  end

  def update
    @tip = Tip.find(params[:id])
    if @tip.update_attributes(params[:tip])
      flash[:notice] = '修改tip成功.'
      redirect_to :action => 'list', :page=>params[:page]
    else
      render :action => 'edit'
    end
  end

  def destroy
    tip = Tip.find(params[:id])
    Tip.delete_all("distance = '#{tip.distance}'")
    
    redirect_to :action => 'list', :t=>tip.t, :page=>params[:page]
  end
  
  def select_functions
    @tip = Tip.find(params[:id])
    @month = Month.find_by_distance(@tip.distance)
  end
  
  def update_functions
    @tip = Tip.find(params[:id])
    @month = Month.find_by_distance(@tip.distance)
    @month.functions = params[:functions].join(',') if params[:functions]
    @month.save
    
    redirect_to :action=>"list", :page=>params[:page], :t=>params[:t], :page=>params[:page]
  end
  
  def download
    send_file "db/data.sqlite3"
  end
end
