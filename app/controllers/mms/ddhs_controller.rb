require 'mamashai_tools/taobao_util'
include MamashaiTools

class Mms::DdhsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def make_taobao_url
    begin        
        token = Weibotoken.get('sina', 'babycalendar')
        user_weibo = UserWeibo.find(:first, :order=>"id desc")
        text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(params[:iid])}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
        res_json = JSON.parse(text)
        if res_json['urls'] && res_json['urls'].size > 0
          @short_url = res_json['urls'][0]["url_short"]
        end
    rescue  Exception=>err
        p "~~~~~~~~~~~~~~~~~~~~~~~~"
          p err
    end

    list
    render :action=>:list
  end

  def list
    @ddhs = Ddh.paginate :page=>params[:page], :per_page => 10, :order=>"order_num desc, status asc, id desc"
  end

  def show
    @ddh = Ddh.find(params[:id])
  end

  def new
    @ddh = Ddh.new
  end

  def create
    @ddh = Ddh.new(params[:ddh])
    if @ddh.save
      flash[:notice] = 'Ddh was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ddh = Ddh.find(params[:id])
  end

  def update
    @ddh = Ddh.find(params[:id])
    @ddh.assign_attributes(params[:ddh])
    if @ddh.save
      flash[:notice] = 'Ddh was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Ddh.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def hide
    ddh = Ddh.find(params[:id])
    ddh.hide = !ddh.hide
    ddh.save
    redirect_to :action=>"list", :page=>params[:page]
  end

  def download_csv
    @orders = DdhOrder.find(:all, :conditions=>"ddh_id = #{params[:id]}")
  end
end
