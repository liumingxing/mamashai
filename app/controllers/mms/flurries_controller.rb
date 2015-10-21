class Mms::FlurriesController < Mms::MmsBackEndController
  def index
    @tongjis = Flurry.paginate :conditions=>"tp = #{params[:tp]||1}", :page => params[:page], :per_page => 30, :order => 'day desc'
  end

  def visit_ios
    @tongjis = Flurry.paginate :conditions=>"tp = 1 and day >= '2015-06-01' and day < '2015-07-01'", :page => params[:page], :per_page => 30, :order => 'day desc'
    render :action=>"visit"
  end

  def visit_android
    @tongjis = Flurry.paginate :conditions=>"tp = 2 and day >= '2015-06-01' and day < '2015-07-01'", :page => params[:page], :per_page => 30, :order => 'day desc'
    render :action=>"visit"
  end

  def list
    conditions = ["tp = #{params[:tp]||1}"]
    conditions << "day > '2014-01-10' " if params[:tp] == '2'
    @tongjis = Flurry.paginate :conditions=>conditions.join(" and "), :page => params[:page], :per_page => 30, :order => 'day desc'
  end

  def create
    @tongji = Flurry.new(params[:tongji])
    @tongji.tp = params[:tp]
    
    if !@tongji.save
      render :action=>"new"
    else
      redirect_to :action=>"index", :tp=>params[:tp]
    end
  end
  
  def edit
    @tongji = Flurry.find(params[:id])
  end
  
  def update
    @tongji = Flurry.find(params[:id])
    @tongji.update_attributes(params[:tongji])
    redirect_to :action => 'index'
  end
  
  def destroy
    case request.method
    when :delete
      @tongji = Flurry.find(params[:id])
      @tongji.destroy
    end
    redirect_to :action => "index"
  end
end
