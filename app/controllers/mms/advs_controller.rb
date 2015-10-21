require 'nokogiri'
require 'open-uri'
class Mms::AdvsController < Mms::MmsBackEndController
  def index
    params[:tp] = params[:tp] || 1
    @advs = Adv.paginate(:page=>params[:page], :per_page=>16, :conditions=>"tp=#{params[:tp]}", :order=>"updated_at desc")
  end
  
  def new
    @adv = Adv.new
  end
  
  def create
    @adv = Adv.new(params[:adv])
    @adv.tp = params[:tp]
    
    if !@adv.save
      render :action=>"new"
    else
      redirect_to :action=>"index", :tp=>params[:tp]
    end
  end
  
  def edit
    @adv = Adv.find(params[:id])
  end

  def update
    @adv = Adv.find(params[:id])
    @adv.update_attributes(params[:adv])
    redirect_to :action=>"index"
  end
  
  def delete
    Adv.find(params[:id]).destroy
    redirect_to :action=>"index", :tp=>params[:tp]
  end

  def create_taoke
    begin
      all = Nokogiri::HTML(params[:taoke])
      @adv = Adv.new(:tp=>params[:tp])
      @adv.desc = all.css('a')[1].text
      @adv.link = all.css('div a')[0]['href']
      @adv.logo = open(all.css('div img')[0]['src'])
      @adv.price = all.css('span').text
      @adv.save
      redirect_to :action=>"index", :tp=>params[:tp]
    rescue
      flash[:notice] = "淘客代码格式错误，请检查"
      render :action => 'index', :tp=>params[:tp] and return
    end
  end
end
