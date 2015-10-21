class Mms::ProvinceController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def list
    @provinces = Province.paginate :per_page=>20, :page=>params[:page]
  end

  def list_cities
    @province = Province.find(params[:id])
    @cities = City.paginate :per_page=>20, :page=>params[:page], :conditions=>"province_id = #{params[:id]}"
  end

  def edit
    @province = Province.find(params[:id])
  end

  def update_province
    @province = Province.find(params[:id])
    if @province.update_attributes(params[:province])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def edit_city
    @city = City.find(params[:id])
  end

  def update_city
    @city = City.find(params[:id])
    if @city.update_attributes(params[:city])
      flash[:notice] = '修改成功.'
      redirect_to :action => 'list_cities', :id=>@city.province_id
    else
      render :action => 'edit_city'
    end
  end

  def update_cities
    params[:city].each{|key, value|
      city = City.find(key)
      city.post_code = value
      city.save
    }
    params[:pinyin].each{|key, value|
      city = City.find(key)
      city.pinyin = value
      city.save
    }
    redirect_to :action=>"list_cities", :id=>params[:id]
  end
end
