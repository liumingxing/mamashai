require 'add_text_to_image'
class ColumnController < ApplicationController
  #before_filter :need_login_user,:need_login_name_user
  before_filter :get_login_user
  layout "main"
  
  before_filter :get_all_authors, :only=>%w(index)
  
  before_filter :to_main


  def to_main
    redirect_to :controller=>"index"
  end

  def get_all_authors
    #chapters = ColumnChapter.published.find(:all, :select=>"distinct(id), column_chapters.*", :order=>"visited_times desc", :limit=>15)
    #@authors = User.find(:all, :conditions=>("id in (#{chapters.collect{|c| c.user_id}.join(',')})"))
    
    @hot_chapters = ColumnChapter.published.find(:all, :conditions=>"created_at > '#{Time.new.ago(7.days).to_s(:db)}'", :order=>"visited_times", :limit=>10)
    @hot_user_chapters = ColumnChapter.find(:all, :group=>"user_id", :conditions=>"created_at > '#{Time.new.ago(30.days).to_s(:db)}'", :select=>"count(id), user_id", :order=>"count(id) desc", :limit=>15)
  end
    
  def index
    conditions = ["posts.`from`='column'"]
    if params[:c]
      authors = ColumnAuthor.find(:all, :conditions=>"category like '%#{params[:c]}%'")
    else
      authors = ColumnAuthor.find(:all)
    end
    #conditions << "column_chapters.id is not null"
    conditions << ["posts.user_id in (#{authors.collect{|a| a.user_id}.join(',')})"]
    @posts = Post.not_hide.paginate(:order=>"id desc", :page=>params[:page], :per_page=>15, :conditions=>conditions.join(' and '), :total_entries=>150)
    @authors = ColumnAuthor.find(:all, :conditions=>"recommend = 1",:limit => 3,:order => "updated_at desc")
    render :layout=>"main"
  end
  
  def author
    if params[:c] && category = ColumnCategory.find_by_id(params[:c]) 
      @authors = ColumnAuthor.find(:all, :conditions=>"category like '%#{category.id}%'", :order=>"#{params[:o]||'chapters'} desc")
    else
      @authors = ColumnAuthor.find(:all, :order=>"#{params[:o]||'chapters'} desc") 
    end
  end
  
  def space_author
    @author = ColumnAuthor.find_by_user_id(params[:id])
    if params[:tp] == 'column'
      @books = ColumnBook.find(:all, :conditions=>"user_id = #{params[:id]}")
    elsif params[:tp] == 'chapter' || !params[:tp]
      cond = ["user_id = #{params[:id]}"]
      cond << "book_id = #{params[:column_id]}" if params[:column_id]
      if @user
        cond << "(draft=0 or (draft=1 and user_id = #{@user.id}))"
      else
        cond << "draft = 0"
      end
      @chapters = ColumnChapter.paginate :page=>params[:page], :per_page=>10, :conditions=>cond.join(' and '), :order=>"id desc"
    elsif params[:tp] == 'view'
    end

    chapters = ColumnChapter.find(:all, :conditions=>"user_id = #{params[:id]}", :limit=>4, :order=>"id desc")
    @hot_readers = ColumnVisit.find(:all, :conditions=>"chapter_id in (#{'-1' + chapters.collect{|c| c.id}.join(',')})", :limit=>6, :order=>"id desc", :group=>"visitor_id")
  end

  #我的专栏--新版
  def space
    @author = ColumnAuthor.find_by_user_id(params[:id])
    unless @author
      redirect_to :action => :all
      return
    end

    @books = Book.paginate :page => params[:page], :per_page => 2, :conditions => ["state = ? and translator_id = ?", "已发布", @author.user_id], :order => "created_at desc"
    sql_where = []
    sql_where << Post.send(:sanitize_sql,["posts.is_hide <> 1"])
    sql_where << Post.send(:sanitize_sql,["posts.user_id =  #{@author.user_id}"])
    sql_where << Post.send(:sanitize_sql,["column_chapters.book_id =  #{params[:column_id]}"]) if params[:column_id]

    @column = ColumnBook.find(params[:column_id]) if params[:column_id]

    if params[:column_id]
      @posts = Post.paginate :page=>params[:page], :per_page=>15,
         :conditions=>sql_where.collect{|c| "(#{c})"}.join(" AND "),
         :joins=>"inner join column_chapters on posts.from_id = column_chapters.id and posts.from = 'column'",
         :order=>"posts.id desc"
    else
      @posts = Post.paginate :page=>params[:page], :per_page=>15,
         :conditions=>sql_where.collect{|c| "(#{c})"}.join(" AND "),
         :order=>"posts.id desc"
    end
         
    if params[:tp] == 'column'
      @books = ColumnBook.find(:all, :conditions=>"user_id = #{params[:id]}")
    elsif params[:tp] == 'chapter'
      cond = ["user_id = #{params[:id]}"]
      cond << "book_id = #{params[:column_id].gsub(".", ".")}" if params[:column_id]
      if @user
        cond << "(draft=0 or (draft=1 and user_id = #{@user.id}))"
        cond << "(access='public' or (access='subject' and subject_id in (#{(@user.subject_ids<<-1).join(',')})))"
      else
        cond << "draft = 0"
        cond << "access = 'public'"
      end
      @chapters = ColumnChapter.paginate :page=>params[:page], :per_page=>10, :conditions=>cond.join(' and '), :order=>"id desc"
    end     
    
    chapters = ColumnChapter.find(:all, :conditions=>"user_id = #{params[:id]}", :limit=>4, :order=>"id desc")
    @hot_readers = ColumnVisit.find(:all, :conditions=>"chapter_id in (#{'-1' + chapters.collect{|c| c.id}.join(',')})", :limit=>6, :order=>"id desc", :group=>"visitor_id")
  end
  
  def show
    params[:id] = params[:chapter_id] if params[:chapter_id]
    @chapter = ColumnChapter.find(params[:id])
    if !@user || @user.id != @chapter.column_book.user.id
      @chapter.column_book.visits += 1
      @chapter.column_book.save
      
      @chapter.visited_times += 6 + rand(3)
      @chapter.save
      
      visitor_id = @user ? @user.id : nil
      visit = ColumnVisit.new(:author_id => params[:id], :book_id => @chapter.book_id, :chapter_id=>@chapter.id, :visitor_id=>visitor_id)
      visit.save
    end
    
    @hot_readers = ColumnVisit.find(:all, :conditions=>"chapter_id = #{params[:id]}", :limit=>6, :order=>"id desc", :group=>"visitor_id")
  end
  
  
  
  #某人的专栏
  def of
    @author = User.find(params[:id])
    @books = ColumnBook.find(:all, :conditions=>"user_id = #{params[:id]}")
  end
  
  #写内容
  def new_chapter
    @books = ColumnBook.find(:all, :conditions=>"user_id = #{@user.id}")
    @chapter = ColumnChapter.new
    @chapter.access = 'public'
    @chapter.tag = "例如职场妈妈 心灵成长"
    @chapter = ColumnChapter.find(params[:chapter_id]) if params[:chapter_id]
  end
  
  #新栏目
  def new
    @column_book = ColumnBook.new
    render :layout=>false
  end
  
  #修改栏目
  def edit
    @column_book = ColumnBook.find(params[:id])
    render :action=>"new", :layout=>false
  end
  
  #协议
  def protocal
    render :layout=>false
  end
  
  #新建或修改栏目
  def create
    @column = ColumnBook.new(params[:column_book])
    @column = ColumnBook.find(params[:id]) if params[:id]
    @column.name = params[:column_book][:name]
    @column.tags = params[:column_type].join(",") if params[:column_type]
    @column.desc = params[:column_book][:desc]
    @column.user_id = @user.id if !@column.user_id
    @column.save
    
    Post.create_post_from_action("我在专栏里创建了新栏目\"#{@column.name}\"，今后会有新作品产生哦，大家保持关注吧！", @user) if !params[:id]
    if params[:id]
      result = "<script>hide_box();</script>"
    else
      result = "<select name='chapter[book_id]'>"
      for c in @user.column_books
        result += "<option value=#{c.id} #{"selected='selected'" if c.id == @column.id}>#{c.name}</option>"
      end
      result += "</select>"  
    end
    
    render :text=>result
  end
  
  #删除栏目
  def destroy
    book = ColumnBook.find(params[:id])
    book.destroy
    redirect_to :action=>"space_author", :id=>book.user_id, :anchor=>"n"
  end
  
  #创建和修改章节
  def create_chapter
    if !params[:chapter_id]
      @chapter = ColumnChapter.new(params[:chapter])
      @chapter.user_id = @user.id
#      @chapter.draft = true if params[:commit].to_s.to_utf8 == "保存到草稿箱"
      @chapter.draft = true if params[:commit] == "1"
      @chapter.save
      #
      if @chapter.errors.size > 0
        logger.info @chapter.errors
        @books = ColumnBook.find(:all, :conditions=>"user_id = #{@user.id}")
        render :action=>"new_chapter"  and return
      end
    else
      @chapter = ColumnChapter.find(params[:chapter_id])
      @chapter.update_attributes(params[:chapter])
#      if params[:commit].to_s.to_utf8 == "保存为草稿"
      if params[:commit] == "1"
        @chapter.draft = true
      else
        @chapter.draft = false
      end
      @chapter.save
    end
    p params[:chapter][:content].encoding
    if !@chapter.draft || @chapter.draft == 0
      post = @chapter.post
      post = Post.new if !post
      post.from = 'column'
      post.from_id = @chapter.id
      post.content = truncate(@chapter.content.gsub(/<(.+?)>/, '').gsub('&nbsp;', ''), :length=>100)
      post.user_id = @user.id
      post.is_hide = false
      logos = @chapter.content.scan(/\/pictureeditor\/(\d+)\/logo/)
      post.logo = PictureEditor.find(logos[0][0]).logo if logos.size > 0
      p "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      p post.content.encoding
      post.save
      if post.errors.size > 0
        logger.info post.errors
      end

      PictureEditor.find(logos.flatten).each do |picture|
        unless  picture.water_print
          new_pic = "#{::Rails.root.to_s}/public#{picture.logo_web.url}"
          old_pic = "#{::Rails.root.to_s}/public#{picture.logo_web.url}"
          AddTextToImage.draw_user_info(old_pic,new_pic,"mamashai.com/#{@user.encrypt_user_id}")
          picture.update_attribute(:water_print, true)
        end
      end

    end
    redirect_to :action=>"space_author", :id=>@user.id, :tp=>"chapter", :column_id=>@chapter.column_book.id
  end
  
  def destroy_chapter
    chapter = ColumnChapter.find(params[:chapter_id])
    if chapter.user_id == @user.id
      chapter.destroy
      if chapter.post
        chapter.post.is_hide = true
        chapter.post.save
      end
    end
    redirect_to :action=>"space_author", :id=>@user.id, :column_id => chapter.book_id, :tp=>"chapter", :anchor=>'n'
  end
  
  def sorry
    chapter = ColumnChapter.find(params[:id])
    post = Post.find(:first, :conditions=>"`from` = 'column' and from_id = #{params[:id]}")
    post = Post.new(:user_id=>chapter.user_id, :from=>'column', :from_id=>params[:id]) if !post
    post.content = truncate(chapter.content.gsub(/<(.+?)>/, '').gsub('&nbsp;', ''), :length=>100)
    post.is_hide = false
    logos = chapter.content.scan(/\/pictureeditor\/(\d+)\/logo/)
    post.logo = PictureEditor.find(logos[0][0]).logo if logos.size > 0
    post.save
    if post.errors.size > 0
      render :text=>"保存失败"
    else
      render :text=>"保存成功"
    end
  end
end
