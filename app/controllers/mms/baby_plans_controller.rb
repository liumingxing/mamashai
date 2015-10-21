class Mms::BabyPlansController < Mms::MmsBackEndController
  
  def index
    @baby_plans = EventBabyPlan.paginate :page => params[:page], :per_page => 10, :order => 'start_at desc'
  end
  
  def new
    @baby_plan = EventBabyPlan.new
  end
  
  def create 
    @baby_plan = EventBabyPlan.new(params[:baby_plan])
    @baby_plan.save 
    redirect_to :action => 'index'
  end
  
  def edit
    @baby_plan = EventBabyPlan.find(params[:id])
  end
  
  def update
    @baby_plan = EventBabyPlan.find(params[:id])
    @baby_plan.update_attributes(params[:baby_plan]) 
    redirect_to :action => 'index'
  end
  
  
end
