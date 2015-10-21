class Mms::BooksController < Mms::MmsBackEndController
  uses_tiny_mce(:options => Article.tiny_advance_options,:only => [:edit, :new])
  
  def index
    page = (params[:page] unless params[:page].blank?) || 1
    @books = Book.paginate(:per_page => 20, :page =>page, :order => "id desc")
  end

  def new
    @book = Book.new(:tags => "")
    @malls = GouSite.all(:conditions => ["state=?" , "publish"])
    @authors = ColumnAuthor.all.collect {|a|[ a.user.name,a.user.id]}
  end

  def create
    if params[:book_content][:content].blank?
      flash[:notice] = "图书内容不能为空！"
      redirect_to :back
    else

      ::Book.transaction do
        params[:book][:mms_user_id] = session[:mms_user_id]
        params[:book][:state] = "未发布"
        params[:book][:unite_recommend] = save_unite_recommend
        params[:book][:book_active] = save_book_active
        @book = ::Book.create(params[:book])

        if @book.errors.blank?
          ::BookContent.create(:content => params[:book_content][:content], :book_id => @book.id)
        end

        save_book_malls  params, @book
      end

      save_book_tag(params[:book][:tag_names], @book)
      save_book_subjects(params[:book][:subjects], @book)

      if @book.errors.blank?
        flash[:notice] = '新增图书成功！'
        redirect_to :action => :index
      else
        flash[:notice] = '新增图书失败！'
        redirect_to :back
      end
    end

  end

  def edit
    @malls = GouSite.all(:conditions => ["state=?" , "publish"])
    @authors = ColumnAuthor.all.collect {|a|[ a.user.name,a.user.id]}
    @book = Book.find(params[:id], :include => "book_content")
    @book_content = @book.book_content
    @book_malls = @book.book_malls
  end

  def update
    if params[:book_content][:content].blank?
      flash[:notice] = "图书内容不能为空！"
      redirect_to :back
    else
      @book = Book.find(params[:id])
      Book.transaction do
        params[:book][:mms_user_id] = session[:mms_user_id]
        params[:book][:unite_recommend] = save_unite_recommend
        params[:book][:book_active] = save_book_active

        @book.update_attributes(params[:book])
        if @book.errors.blank?
          @book.book_content.update_attribute(:content, params[:book_content][:content])
        end

        save_book_malls  params, @book
      end

      save_book_tag(params[:book][:tag_names], @book)
      save_book_subjects(params[:book][:my_subjects], @book)
      if @book.errors.blank?
        flash[:notice] = '修改图书成功！'
        redirect_to :action => :index
      else
        flash[:notice] = '修改图书失败！'
        redirect_to :back
      end
    end

  end

  def find
    page = (params[:page] unless params[:page].blank?) || 1
    if params[:search][:title].blank?
      redirect_to :action => :index
      return
    end
    @books = Book.paginate(:per_page => 20, :page =>page, :conditions=>["book_name like ? or book_contents.content like ?","%#{params[:search][:title]}%", "%#{params[:search][:title]}%"], :include => [:book_content], :order => "books.created_at DESC")
    render :action => :index
  end

  def publish
    article = Book.find(params[:id])
    flash[:notice] = "修改图书发布状态成功！"
    flash[:notice] = "修改图书发布状态失败！" if !article.update_attribute(:state, "已发布")
    redirect_to :action => :index
  end

  def unpublish
    article = Book.find(params[:id])
    flash[:notice] = "修改图书发布状态成功！"
    flash[:notice] = "修改图书发布状态失败！" if !article.update_attribute(:state, "未发布")
    redirect_to :action => :index
  end



  def destroy
    @book = Book.find(params[:id])
    flash[:notice] = '删除图书成功！'
    flash[:notice] = '删除图书失败！' unless @book.destroy
    redirect_to :action => :index
  end

  private
  def parse_search_key(keys)
    #keys.scan(/(\w+?)/).flatten
    keys.split(" ")
  end

  def save_book_malls(params, book)
    book.book_malls.delete_all

    GouSite.all.collect{|gs| gs.id}.each do |id|
      unless params["book_malls_#{id}"].blank?
        book_mall = BookMall.new
        book_mall.gou_site_id = id
        book_mall.book_mall_url = params["book_malls_#{id}"]
        book_mall.order_number = params["book_malls_order_number_#{id}"]
        book.book_malls <<  book_mall
      end
    end
  end

  def save_book_tag(tags, book)
    book.tags.delete_all
    parse_search_key(tags).each do |tag_name|
      tag = Tag.create_tag_from_post(tag_name)
      book.tags << tag
    end
  end

  def save_book_subjects(subjects, book)
    book.book_subjects.delete_all
    parse_search_key(subjects).each do |subject_name|
      subject = Subject.find_by_name(subject_name)
      book.subjects << subject if subject
    end
    book.update_attribute(:my_subjects, "") if book.subjects.size == 0
  end

  def save_unite_recommend
    unites = []
    4.times do |t|
      unites << params["book_unite_recommend_#{t}"] unless params["book_unite_recommend_#{t}"].blank?
    end
    unites.join("$")
  end

  def save_book_active
    actives = []
    5.times do |t|
      actives << "#{params["book_active_name_#{t}"]}##{params["book_active_url_#{t}"]}" unless params["book_active_name_#{t}"].blank?
    end
    actives.join("$")
  end

end
