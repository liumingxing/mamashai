class Api::TestController < Api::ApplicationController
  layout "test"
  
  def apicall_log
      
  end
  
  def index_84873560
    render :action=>"index"  
  end
  
  def api_provinces
    @provinces = Province.all(:include=>[:cities])
  end
  
  def api_ages
    @ages = Age.all
  end
  
end