class Mms::TagsController < Mms::MmsBackEndController
  
  ########话题设置###########
  def age_tags
    @csv=AgeTag.build_age_tags_csv
  end
  
  def build_age_tags
    if params[:age_tags_csv].blank?
      flash[:notice] = APP_CONFIG['error_message_age_tags_csv_format_error']
      @csv=params[:age_tags_csv]
      render :action=>:age_tags
      return
    end
    if AgeTag.rebuild_age_tags params[:age_tags_csv]
      flash[:notice] = APP_CONFIG['rebuild_age_tags_success']
    else
      @csv=params[:age_tags_csv]
      flash[:notice] = APP_CONFIG['error_message_age_tags_csv_format_error']
      render :action=>:age_tags
      return
    end
    redirect_to :action=>:age_tags
  end
  
  ########话题管理###########
  def great_tags
    @tag = NameValue.find_by_name('today_tag')
    @title = NameValue.find_by_name('today_title')
    @name_value = NameValue.new(:name=>@tag.value,:value=>@title.value)
    @broadcast_tags = NameValue.find_by_name('broadcast_tag').value.split('|')
    @hot_tags = NameValue.find_by_name('day_hot_tags').value.split('|')
  end
  
  def age_subjects
    #render :text=>"hello"
  end
  
  def update_great_tags
    @tag = NameValue.find_by_name('today_tag')
    @tag.value = params[:name_value][:name]
    @tag.save
    @title = NameValue.find_by_name('today_title')
    @title.value = params[:name_value][:value]
    @title.save
    redirect_to "/pub"
  end
  
  def update_broadcast_tag
    tag_names = []
    for i in 0..2
      tag_names << params[:broadcast_tag][i.to_s]
    end
    name_value = NameValue.find_by_name('broadcast_tag')
    name_value.value = tag_names.join("|")
    name_value.save
    redirect_to "/groups"
  end
  
  def update_day_hot_tags
    tag_names = []
    for i in 0..7
      tag_names << params[:tag_names][i.to_s]
    end
    name_value = NameValue.find_by_name('day_hot_tags')
    name_value.value = tag_names.join("|")
    name_value.save
    redirect_to "/home/shine"
  end
  
end
