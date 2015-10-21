class Mms::CalendarTipAdvsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @calendar_tip_advs = CalendarTipAdv.paginate :page=>params[:page], :per_page => 10, :order=>"status desc, id desc"
  end

  def show
    @calendar_tip_adv = CalendarTipAdv.find(params[:id])
  end

  def new
    @calendar_tip_adv = CalendarTipAdv.new
  end

  def create
    @calendar_tip_adv = CalendarTipAdv.new(params[:calendar_tip_adv])
    if @calendar_tip_adv.save
      flash[:notice] = 'CalendarTipAdv was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar_tip_adv = CalendarTipAdv.find(params[:id])
  end

  def update
    @calendar_tip_adv = CalendarTipAdv.find(params[:id])
    if @calendar_tip_adv.update_attributes(params[:calendar_tip_adv])
      flash[:notice] = 'CalendarTipAdv was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    CalendarTipAdv.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def tongji
    @tip = CalendarTipAdv.find(params[:id])
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_#{@tip.id}'`
    @json = JSON.parse(text)

    sleep(1)
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=zhinan_advertisement_click_#{@tip.id}'`
    @json_click = JSON.parse(text)
  end
end
