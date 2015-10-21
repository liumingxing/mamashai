class Mms::AmountEventRefersController < Mms::MmsBackEndController
  
  def index
    @events = Mms::AmountEventHit.paginate(:per_page => 20,:page => params[:page], :order => "amount DESC")
  end
  
  def show
    @event_refers = Mms::AmountEventRefer.paginate(:per_page => 20,:page => params[:page], :conditions => {:mms_amount_event_hit_id => params[:id]}, :include => [:mms_amount_event_hit], :order => "amount DESC")
  end
  
  def amount_with_http_refer
    amount_event = Mms::AmountEventHit.find(:params[:id])
  end
  
  def find
    events = Mms::Event.paginate(:per_page => 20,:page => params[:page], :order => "created_at DESC")
    http_refers = HttpRefer.all
    ActiveRecord::Base.transaction do
      for event in events
        amount_event = Mms::AmountEventHit.first(:conditions => {:url => event.url})
        amount = amount(event, http_refers)
        if amount_event.blank?
          amount_event = Mms::AmountEventHit.new(:event_name => event.name, :url => event.url, :image_url => event.image_url, :begin_time => event.begin_time, :end_time => event.end_time, :amount => amount)
        else
          amount_event.amount = amount
        end
        if amount_event.save
          create_amount_http_refer(event, http_refers, amount_event)
        end
      end
    end
    redirect_to :action => :index
  end
  
  def amount(event, http_refers)
    amount = 0
    for http_refer in http_refers
      amount += 1 if event.url == http_refer.link
    end
    return amount
  end
  
  def create_amount_http_refer(event, http_refers, amount_event)
    event_http_refers = HttpRefer.all(:having => "link = '#{event.url}'", :group => :http_refer)
    for event_http_refer in event_http_refers
      http_refer_amount = http_refer_amount(http_refers, event_http_refer)
      amount_event_refer = Mms::AmountEventRefer.first(:conditions => {:mms_amount_event_hit_id => amount_event.id, :http_refer => event_http_refer.http_refer})
      if amount_event_refer.blank?
        Mms::AmountEventRefer.create(:mms_amount_event_hit_id => amount_event.id, :link => event_http_refer.link, :http_refer => event_http_refer.http_refer, :amount => http_refer_amount )
      else
        amount_event_refer.update_attribute(:amount, http_refer_amount)
      end
    end
  end
  
  def http_refer_amount(http_refers, event_http_refer)
    amount = 0
    for http_refer in http_refers
      amount += 1 if http_refer.http_refer == event_http_refer.http_refer
    end
    return amount
  end

end
