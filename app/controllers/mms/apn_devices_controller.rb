class Mms::ApnDevicesController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    conditions = ["1=1"]
    conditions << "users.name like '%#{params[:name]}%'" if params[:name]
    conditions << "users.age_id in (#{params[:age].join(",")})" if params[:age]
    @apn_devices = ApnDevice.paginate :joins=>"left join users on users.id = apn_devices.user_id", 
      :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>conditions.join(" and ")
  end

  def push
    MamashaiTools::ToolUtil.push_aps(params[:user_id], params[:text])
    render :text=>"<script>push_success();</script>"
  end

  def messages
    @messages = ApnMessage.paginate :page=>params[:page], :per_page=>10, 
      :conditions=>"user_id = #{params[:id]}", :order=>"id desc"
  end

  def show
    @apn_device = ApnDevice.find(params[:id])
  end

  def new
    @apn_device = ApnDevice.new
  end

  def create
    @apn_device = ApnDevice.new(params[:apn_device])
    if @apn_device.save
      flash[:notice] = 'ApnDevice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @apn_device = ApnDevice.find(params[:id])
  end

  def update
    @apn_device = ApnDevice.find(params[:id])
    if @apn_device.update_attributes(params[:apn_device])
      flash[:notice] = 'ApnDevice was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    ApnDevice.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def make_broadcast
    keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
    jpush_keys = %w(b789c8ed387ca31a1569c932:78ab7b77f32b35deccf4b847 9c75b77425cb280bc1c975fe:e2917386120a007763cb468e 8ea7cf97ac67608ba65c2db7:75c7d17c756279565ceb2b6f)
    
    if params[:id].to_i >= 4
      result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[params[:id].to_i-4]}" -d '{"platform":"android","audience":"all","notification":{"alert":"#{params[:text]}"}}'!
    else
      ApnDevice.broadcast_apn(params[:id].to_i, params[:text])
    end
    redirect_to :action=>"broadcast"
  end

  def make_broadcast2
    extras = {}
    extras[:t] = params[:t] if params[:t] && params[:t].size > 0
    if extras[:t] == "post"
      extras[:id] = params[:id] if params[:id].to_s.size > 0
    end

    if extras[:t] == "url2"
      extras[:url] = params[:id] if params[:id].to_s.size > 0
    end

    1.upto(6) do |index|
      keys = %w(JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ JTN_DI7gR9e45j_JUBCz6A:A2R0Bf_vSLm40wYLYoP4HQ HeMgqDP4SHKrZAn_dS_p1A:GROO_u1AQPi-XLRh9O7ixg 7vYTvD1ISfavgtt-MeQJwg:nWfmYnDhRcKNnNagbMs7tQ)
      jpush_keys = %w(b789c8ed387ca31a1569c932:78ab7b77f32b35deccf4b847 9c75b77425cb280bc1c975fe:e2917386120a007763cb468e 8ea7cf97ac67608ba65c2db7:75c7d17c756279565ceb2b6f)
      
      if index >= 4
        result = MamashaiTools::ToolUtil.fork_command %Q!curl -X POST -v https://api.jpush.cn/v3/push -H "Content-Type: application/json" -u "#{jpush_keys[index-4]}" -d '{"platform":"android","audience":"all","notification":{"alert":"#{params[:text]}", "extras": #{extras.to_json} }}'!
      else
        ApnDevice.broadcast_apn(index, params[:text], extras)
      end

    end

    redirect_to :action=>"broadcast"
  end
end
