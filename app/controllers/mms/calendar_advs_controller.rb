class Mms::CalendarAdvsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @calendar_advs = CalendarAdv.paginate :page=>params[:page], :per_page => 10, :order=>"status desc, position, id desc"
  end

  def show
    @calendar_advs = CalendarAdv.find(params[:id])
  end

  def new
    @calendar_advs = CalendarAdv.new
  end

  def create
    @calendar_advs = CalendarAdv.new(params[:calendar_advs])
    if @calendar_advs.save
      Rails.cache.delete("half_screen_advs_android")
      Rails.cache.delete("half_screen_advs_ios")
      flash[:notice] = 'CalendarAdv was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @calendar_advs = CalendarAdv.find(params[:id])
  end

  def update
    @calendar_advs = CalendarAdv.find(params[:id])
    if @calendar_advs.update_attributes(params[:calendar_advs])
      Rails.cache.delete("half_screen_advs_android")
      Rails.cache.delete("half_screen_advs_ios")
      flash[:notice] = 'CalendarAdv was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    CalendarAdv.find(params[:id]).destroy
    Rails.cache.delete("half_screen_advs_android")
    Rails.cache.delete("half_screen_advs_ios")
    redirect_to :action => 'list'
  end

  def tongji
    @tip = CalendarAdv.find(params[:id])
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=calendar_advertisement_#{@tip.id}'`
    @json = JSON.parse(text)

    sleep(2)
    text = `curl 'http://api.flurry.com/eventMetrics/Event?apiAccessCode=NP7JWXVZ1X5LRFVBJ58G&apiKey=ZLLEP9WR3RUHHQ5XKMUY&startDate=#{@tip.created_at.to_date.to_s(:db)}&endDate=#{@tip.status == 'online' ? Time.new.to_date.to_s(:db) : @tip.updated_at.to_date.to_s(:db)}&eventName=calendar_advertisement_click_#{@tip.id}'`
    @json_click = JSON.parse(text)
  end
end
