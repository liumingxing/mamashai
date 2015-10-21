class Mms::TopicTagsController < Mms::MmsBackEndController
  def index
    @ages = Age.all
  end


  def list_tags
    @age = Age.find(params[:id])
    @age_tags = @age.age_tags.all(:order => "updated_at desc", :conditions => "age_tags.tp = 0")
  end
  
  def new_tag
    @age_tag = AgeTag.new
    @age = Age.find(params[:age_id])
  end

  def edit_tag
    @age_tag = AgeTag.find(params[:id])
  end
  
  def to_top
    age_tag = AgeTag.find(params[:id])
    age_tag.updated_at = Time.new
    age_tag.save
    redirect_to :action=>"list_tags", :id=>age_tag.age_id
  end

  def set_week_hot
    AgeTag.update_all "week_hot=0"
    age_tag = AgeTag.find(params[:id])
    age_tag.week_hot = true
    age_tag.save

    flash[:notice] = "设置周话题成功"
    redirect_to :action=>"list_tags", :id=>age_tag.age_id
  end
  
  def create_tag
    for age_id in params[:age]
      age = Age.find(age_id)
      tag = Tag.find_by_name(params[:tag][:name])
      tag = Tag.create(:name => params[:tag][:name]) unless tag
  
      params[:age_tag][:age_id] = age_id
      params[:age_tag][:tag_id] = tag.id
      params[:age_tag][:is_index_hot] = params[:age_tag][:logo] ? true : false
      params[:age_tag][:tp] = 0
      AgeTag.create(params[:age_tag])
    end
    redirect_to :action=>"list_tags", :id=>params[:age_id]
  end

  def update_tag
    age_tag = AgeTag.find(params[:id])
    age_tag.update_attributes(params[:age_tag])
    redirect_to :action=>"list_tags", :id=>age_tag.age_id
  end
  
  def delete_tag
    age_tag = AgeTag.find(params[:id]).destroy
    redirect_to :action=>"list_tags", :id=> age_tag.age_id
  end

  def show_pic_text_tag
    age_tag = AgeTag.find(params[:id])

    flash[:notice] = "设为图文话题成功！"
    flash[:notice] = "设为图文话题失败！" if !age_tag.update_attribute(:is_index_hot, 1)
    redirect_to :action => :list_tags , :id => age_tag.age_id
  end

  def hide_pic_text_tag
    age_tag = AgeTag.find(params[:id])
    flash[:notice] = "取消图文话题成功！"
    flash[:notice] = "取消图文话题失败！" if !age_tag.update_attribute(:is_index_hot, 0)
    redirect_to :action => :list_tags , :id => age_tag.age_id
  end
  
  def regular_topics
    @age = Age.find(params[:id])
  end

  def create_regular
    age = Age.find(params[:id])
    age.update_attributes(params[:age])
    redirect_to :action=>"index"
  end
end
