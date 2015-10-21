class GouController < ApplicationController
  before_filter :to_tao
  
  def to_tao
    redirect_to :controller=>"tao"
  end

  def method_missing(args)
  	redirect_to :controller=>"tao"
  end
end
