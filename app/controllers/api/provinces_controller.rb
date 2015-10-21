class Api::ProvincesController < Api::ApplicationController
  
  def index
    @provinces = Province.all(:include=>[:cities], :conditions=>"country_code = '001'")
    render :json=>@provinces.to_json(:only=>[:id,:name], :include=>{:cities=>{:only=>[:id,:name]}})
  end
  
end