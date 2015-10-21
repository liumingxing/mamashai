class Mms::ColumnController < Mms::MmsBackEndController
  uses_tiny_mce(:options => Article.tiny_advance_options,:only => [:edit, :new])

  def index
    @authors = ColumnAuthor.paginate :page=>params[:page], :per_page=>10
  end
   
  def new
    @author = ColumnAuthor.new
  end
  
  def create
    user = ::User.find_by_email(params[:email])
    if user
      if ColumnAuthor.find_by_user_id(user.id)
        flash[:notice] = "这个用户已经是专栏作者了"
      else
        author = ColumnAuthor.new
        author.user_id = user.id
        author.save
      end
    else
      flash[:notice] = "找不到这个用户"
      redirect_to :action=>"new"
      return
    end
    
    redirect_to :action=>"index"
  end
  
  def edit
    @author = ColumnAuthor.find(params[:id])
  end
  
  def update
    @author = ColumnAuthor.find(params[:id])
    @author.update_attributes(params[:author])
    @author.update_attribute(:category, params[:category_ids].join(',')) if params[:category_ids]
    redirect_to :action=>"index"
  end
  
  def destroy
    ColumnAuthor.find(params[:id]).destroy
    redirect_to :action=>"index"
  end


  #首页、未登录页专栏文章标题管理

  def last_columns
    @tp = params[:tp] || "all"
    @column_authors = ColumnAuthor.get_column_author_by_last_chapter(4, @tp)

    if @tp == "all"
      @title = "您可以为首页专栏标题添加短标题"
      @link = "<a href='/mms/column/last_columns?tp=part'>修改</a>"
    else
      @title = "您可以修改首页已经维护过的专栏短标题"
      @link = "<a href='/mms/column/last_columns?tp=all'>添加</a>"
    end
  end

  def create_short_title
    flash[:notice] = "操作失败"
    chapter_ids = params[:chapter_id]
    redirect_to :action => :last_columns and return if chapter_ids.blank?

    ColumnChapter.update_all("short_title = null","short_title is not null")
    chapter_ids.each do | chapter_id|
      chapter = ColumnChapter.find_by_id(chapter_id)
      chapter.update_attribute(:short_title, params["short_title_#{chapter_id}"]) if chapter
    end

    flash[:notice] = "操作成功"
    redirect_to :back
  end
  def recommend
      @author = ColumnAuthor.find(params[:id])
  end
  def recommend_save
      @author = ColumnAuthor.find(params[:id])
      if @author.update_attributes(params[:author])
        flash[:notice] = "操作成功"
        redirect_to :action=>"index"
      else
        flash[:notice] = "操作失败"
        redirect_to :action=>"recommend"
      end
  end
end

