class AjaxController < ApplicationController 
  layout nil
  
  before_filter :ajax_need_login_user,:except=>[:get_search_tp, :get_tags_for_no_login, :list_article_comments, :list_comments, :get_cities2, :get_cities,:get_emails,:get_eproduct_tags,:get_pub_sidebar_age_tags, :list_tuan_comments, :get_post_topic_tag_of_ages_for_hot_topic, :get_post_age_tags]
  before_filter :get_login_user, :only => [:list_tuan_comments, :list_comments, :list_article_comments]
  before_filter :get_follow_user_ids, :only=>[:same_age_kid, :same_kind_users, :clap_users]
  
  skip_before_filter :verify_authenticity_token

  def get_cities  
  end

  def get_cities2
    @province = Province.find(params[:id])
    result = "<select id='city_id' name='city_id'>"
    for city in @province.cities
      result << "<option value='#{city.id}'>#{city.name}</option>"
    end
    result << "</select>"
    render :text=>result
  end
  
  def show_picture
    render :text=>"<img src='#{params[:pic]}'/>"
  end

  def get_tuan_cities
    
  end
  
  def get_eproduct_tags
  end
  
  def get_emails
    emails = MamashaiTools::HttpUtil.get_common_emails(params[:search])
    if emails.blank?
      render :text=>'' and return false
    end
    emails = emails.collect{|email| "<li><a title='#{email}' href='javascript:void(0)' class='item choose-value'>#{email}</a></li>" } 
    render :text=>"<ul>#{emails.join('')}</ul>"
  end
  
  def get_post_age_tags
    unless params[:id].blank? 
      @age = Age.find(params[:id])
      #@tags = (params[:tp]=='ask' ?  @age.ask_tags : @age.post_tags)
    end
  end

  def get_post_topic_tag_of_ages
    unless params[:id].blank?
      @age = Age.find(params[:id])
      @age_tags = @age.age_tags.all(:conditions => ["tp = ?",0],:order => "age_tags.updated_at desc",:limit => 5)
    end
  end

  def get_post_topic_tag_of_ages_for_hot_topic
    unless params[:id].blank?
      @age = Age.find(params[:id])
      @hot_topics = @age.age_tags.all(:conditions => ["tp = ?",0],:order => "age_tags.updated_at desc",:limit => 5)
    end
  end

  def get_tags_for_no_login
    unless params[:id].blank?
      @age = Age.find(params[:id])
      @hot_topics = @age.age_tags.all(:conditions => ["tp = ?",0],:order => "age_tags.updated_at desc",:limit => 10)
    end
  end

  def get_ask_sidebar_age_tags
    unless params[:id].blank? 
      @age = Age.find(params[:id])
      @tags = @age.ask_tags
    end
  end
  
  def get_pub_sidebar_age_tags
    unless params[:id].blank? 
      @age = Age.find(params[:id])
      @tags = @age.post_tags
    end
  end
  
  ############# sidebar ################
  
  def get_sidebar_age_tags
    unless params[:id].blank? 
      @age = Age.find(params[:id])
      @tags = (params[:tp]=='ask' ?  @age.ask_tags : @age.post_tags)
      @favorite_tag_ids = Tag.user_favorite_tags(@user).collect{|tag| tag.id}
    end
  end
  
  def set_favorite_tags
    tag_ids = params[:tag_ids].collect{|m| m[0] if m[1]=='1'}.compact
    FavoriteTag.create_favorite_tags(tag_ids,@user)
  end
  
  def delete_sidebar_favorite_tag
    @tag = Tag.find(params[:id])
    FavoriteTag.find_by_tag_id_and_user_id(@tag.id,@user.id).destroy
    render :action=>'set_favorite_tags'
  end
  
  
  def get_sidebar_follow_users
    @groups = @user.follows_groups
    if params[:id].present? && params[:id]!='0'
      @group = FollowsGroup.find(params[:id])
    end
    BestFollowUser.create_best_follow_user(params,@user) if params[:follow_ids].present?
    conditions = []
    conditions = ["follow_users.follows_group_id=?",@group.id] if @group
    @follows = @user.follows.paginate(:page=>params[:page],:per_page=>20,:conditions=>conditions,:order=>"follow_users.id desc")
    @best_follow_ids = @user.best_follows.collect{|follow| follow.id }
  end
  
  def set_best_follows 
    BestFollowUser.create_best_follow_user(params,@user)
    @follow_user_ids = @user.follow_user_ids if @user
    @best_follows = User.find(@user.id).best_follows
  end
  
  ############# sidebar ################
  
  def follow_groups
    
  end
  
  def create_follow_group
    begin
      group = FocusUserGroup.create(:name=>params[:name],:user_id=>@user.id)
      render :text=>group.to_json(:only=>[:id,:name])
    rescue
      render :text=>"{error:1}"
    end
  end
  
  def update_follow_group 
    begin
      group = FocusUserGroup.find(params[:id])
      group.update_attributes(:name=>params[:name])
      render :text=>group.to_json(:only=>[:id,:name,:follow_users_count]) 
    rescue
      render :text=>"{error:1}"
    end
  end
  
  ################# need login ####################
  
  def get_search_tp
    @search_name = params[:search].strip if params[:search] 
  end
  
  ################# post ####################
  
  def dd_menu_update_post
    @post = Post.find(params[:id])
    if params[:age_id]
      render :text=>'error' and return false if @post.age_id.present?
      @age = Age.find(params[:age_id])
      @post.update_attributes(:age_id=>params[:age_id])
      render :text=>"<a href='/home/find_posts?age_id=#{@post.age_id}'>[#{@age.name}]</a>" and return false
    end
    if params[:tag_id]
      render :text=>'error' and return false if @post.tag_id.present?
      @tag = Tag.find(params[:tag_id])
      @post.update_attributes(:tag_id=>@tag.id,:category_id=>@tag.category_id,:content=>"[#{@tag.name}]#{@post.content}")
      Post.add_post_tag_score(@post,@user)
      render :text=>"<a href='/home/find_posts?tag_id=#{@post.tag_id}'>[#{@tag.name}]</a>" and return false
    end
    if params[:tag_name]
      @tag = Tag.find_by_name(params[:tag_name])
      @tag = Tag.create_tag(params[:tag_name],1) unless @tag
      if @tag.errors.empty?
        @post.update_attributes(:tag_id=>@tag.id,:category_id=>@tag.category_id,:content=>"[#{@tag.name}]#{@post.content}")
        Post.add_post_tag_score(@post,@user)
      end
      render :text=>"<a href='/home/find_posts?tag_id=#{@post.tag_id}'>[#{@tag.name}]</a>" and return false
    end
    render :text=>'error'
  end 
  
  def select_rate_star
    @post = Post.find(params[:id])
    @post_rate = PostRate.create_post_rate(params,@post,@user)
    @post = Post.find(params[:id])
  end
  
  def clap
    return '(0)' unless params[:id]
    
    if Clap.count(:conditions=>"tp_id = #{params[:id]} and tp = '#{params[:tp]}' and user_id = #{@user.id}") >= 1
      render :text=>"(点过了)"
      return
    end
    
    clap = Clap.new
    clap.user_id = @user.id
    clap.tp_id = params[:id]
    clap.tp = params[:tp]
    clap.save

    product = TaobaoProduct.find_by_id params[:id]
    if product
      product.update_attribute :like_count, product.like_count.to_i + 1
    end
    
    if params[:tp] == 'post'
      post = Post.find(params[:id])
      post.claps_count += 1
      post.save
      MamashaiTools::ToolUtil.add_unread_infos(:create_favorite_post, {:user=>post.user})
      
      if post.from == 'column'
        post.column_chapter.column_book.handclaps += 1
        post.column_chapter.column_book.save
      end
      
      render :text=>"(#{post.claps_count})" 
    elsif params[:tp] == 'article'
      article = Article.find(params[:id])
      article.good_count += 1
      article.save
      render :text=>"(#{article.good_count})"
    else 
      render :text=>"(" + (Clap.count(:conditions=>"tp='#{params[:tp]}' and tp_id = #{params[:id]}")).to_s + ")"
    end
  end
  
  ################# user links ##################
  
  def add_user_link
    @sys_link = SysLink.find(params[:id])
    @link_category = @sys_link.link_category
    UserLink.create(:name=>@sys_link.name,:url=>@sys_link.url,:link_category_id=>@sys_link.link_category_id,:user_id=>@user.id,:sys_link_id=>@sys_link.id)
  end
  
  def delete_user_link
    @user_link = UserLink.find(params[:id])
    @sys_link = @user_link.sys_link 
    @link_category = @user_link.link_category
    @user_link.destroy
  end
  
  def get_category_user_links
    @link_category = LinkCategory.find(params[:id])
  end
  
  def new_user_link
    @user_link = UserLink.new
    @link_category = LinkCategory.find(params[:id])
    @user_link.link_category_id = @link_category.id
    @user_link.url = 'http://'
  end
  
  def create_user_link
    @user_link = UserLink.new(params[:user_link])
    @user_link.user = @user
    @user_link.save
    @link_category = @user_link.link_category
  end 
  
  def delete_link_category
    link_category_ids = ['4','5','6','7']
    link_category_ids = @user.link_category_ids.split(',') if @user.link_category_ids
    link_category_ids.delete(params[:id])
    @user.link_category_ids = link_category_ids.join(',')
    @user.save
    render :text=>"<script>Element.remove('link_category_#{params[:id]}');</script>"
  end
  
  ################# comments ############################
  #针对照片进行评论
  def create_picture_comment
    picture = Picture.find(params[:id])
    post = Post.new
    post.content = params[:comment][:content]
    post.from = 'picture'
    post.from_id = params[:id]
    post.user_id = @user.id
    post.logo = picture.logo
    post.save
    render :partial=>'create_picture_comment', :locals => {:post => post}
  end
  
  def list_comments
    @post = Post.find(params[:id])
  end
  
  def list_article_comments
    @article = Article.find(params[:id])
    render :partial=>"/articles/article_comments"
  end
  
  def create_comment
    if Blockname.find_by_user_id(@user.id)
      redirect_to :action=>'list_comments',:id=>@post.id and return
    end

    @post = Post.find(params[:id])
    @comment = Comment.create_comment(params,@user,@post)
    unless @comment.errors.empty?
      render :action=>'list_comments' and return false 
    end
    
    if @comment.rate.present?
      Comment.set_post_rate(@post)
    end
    
    @comment = Comment.new if @comment.errors.empty?
    if @post.from == 'column'
      @post.column_chapter.column_book.comments += 1
      @post.column_chapter.column_book.save
    end
    
    redirect_to :action=>'list_comments',:id=>@post.id
  end
  
  def create_article_comment
    article = Article.find(params[:id])
    article_comment = ArticleComment.create_article_comment(params, @user, article) if article.present?
    
    post = Post.create_forward_post(params[:comment][:content], @user, article.post) if params[:is_copy_post]=="on" && article.post
    redirect_to :action => "list_article_comments", :id => article.id
  end
  
  def delete_confirm_comment
    @update_id = "post_expand_#{params[:post]}"
    @ajax_action = 'delete_comment'
    render :action=>'delete_confirm'
  end
  
  def delete_comment
    @post = Comment.delete_comment(params[:id],@user)
    return render_404 unless @post
    render :text=>"删除评论成功"
  end

  def delete_article_comment
    comment = ArticleComment.find(params[:id])
    comment.destroy
    render :text=>"删除评论成功"
  end
  
  # delete comment in home comments list
  def delete_post_comment
    Comment.delete_post_comment(params[:id],@user)
    render :text=>"<script>forwardshine_dialog.content('成功删除').time(2000).button({id: 'ok', value: '确定',disabled: false});$('#comment_wapper_#{params[:id]}').fadeOut();</script>"
  end
  
  def create_reply_comment
    @post = Post.find(params[:id])
    @comment = Comment.create_comment(params,@user,@post)
  end
  
  
  def select_best_answer
    @comment = Comment.find(params[:id])
    @post = @comment.post
    @post.best_answer_id = @comment.id
    @post.save 
    @comment = Comment.new
    render :action=>'list_comments'
  end
  
  ################# books ###################
  
  def book_generate_confirm
    @user_book = UserBook.find(params[:id])
  end
  
  def book_add_page_post
    @user_book = UserBook.find(params[:id])
    if @user_book.user_book_pages_count < 66
      @post = Post.find(params[:post])
      UserBook.add_book_post(@user_book,@post,@user)
    end
  end
  
  def book_delete_page_post
    @user_book = UserBook.find(params[:id])
    @post = Post.find(params[:post])
    @book_page = UserBookPage.find(:first,:conditions=>['user_book_id=? and post_id=?',@user_book.id,@post.id])
    UserBook.delete_book_page(@user_book,@book_page,@user) if @book_page
  end
  
  def book_update_page_text
    @user_book = UserBook.find(params[:id])
    @book_page = UserBookPage.find(:first,:conditions=>['user_book_id=? and id=?',@user_book.id,params[:book_page_id]])
    @book_page.update_attributes(params[:book_page])
    if params[:content] == '1'
      post = @book_page.post
      if post
        post.content = @book_page.content1
        post.save
      end
    end
  end
  
  ################# messages ############################
  
  def new_message
    @message_post = MessagePost.new
    if params[:id]
      @message_user = User.find(params[:id])
      @message_post.user_name = @message_user.name
      @message_post.content = params[:content].to_utf8 if params[:content]
    end
  end
  
  def create_message
    @message_post = MessagePost.create_message_post(params,@user)
    unless @message_post.errors.empty?
      #render :text=>"{error:'#{@message_post.errors[:user_name]}'}" and return false
      render :action=>"_new_message_form", :layout=>false and return false
    end
    render :text=>"<script>hide_box();</script>"
    #render :text=>'{success:1}'
  end
  
  #################### follows #########################
  
  def list_follow_users
    @users = User.find_follow_users(@user,params)
  end
  
  def select_follow_users
    @user_names = params[:user_names].collect{|m| m[0] if m[1]=='1'}.compact if params[:user_names]
  end
  
  ################# recommend ############################
  
  def new_recommend
    @post = Post.new 
    @recommend_user = User.find(params[:id])
    @post.content = "#{APP_CONFIG['quik_look']} @#{@recommend_user.name} #{APP_CONFIG['de']}#{APP_CONFIG['space']}"
  end
  
  def create_recommend
    @post = Post.new(params[:post])
    Post.create_post(params,@user) 
    render :action=>'success'
  end
  
  def edit_post_new_title 
    @post = Post.find(params[:id])
  end
  
  def update_post_new_title
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
  end
  ################## forward post ##########################
  
  def new_forward_post
    @post = Post.new
    @the_post = Post.find(params[:id])
    @from = params[:from]
    @forward_post = @the_post
    if @the_post.forward_post_id
      @post.content = "//@#{@the_post.user.name}:#{@the_post.content}"
    end
  end  
  
  def create_forward_post
    @post = Post.new(params[:post])
    # only for the forward post owner
    if params[:the_post_id] != params[:id]
      the_post = Post.find(params[:the_post_id])
      Post.update_all(["forward_posts_count=?",the_post.forward_posts_count+1],["id=?",the_post.id])  
    end
    orig_post = Post.find(params[:id])
    post = Post.create_forward_post(@post.content,@user, orig_post) 
    if orig_post.from == 'column'
        orig_post.column_chapter.column_book.fowards += 1
        orig_post.column_chapter.column_book.save
    end
    
    #同时评论给原微博作者
    if params[:is_comment] == "1" || params[:is_comment] == "true"
      attr = {:comment=>{:content=>URI::decode(params[:post][:content])}}
      comment = Comment.create_comment(attr, @user, orig_post)
    end
      
    if params[:from] == 'home'
      render :update do |page|
        page << 'window.scrollTo(0,200)'
        page.delay(0.2){
          page.insert_html :after,'mms_index_title', :partial=>'home/user_content',:locals=>{:post=>post}
          page << "$('#post_wapper_#{post.id}').hide();"
          page << "$('#post_wapper_#{post.id}').show('slow')"
          #page.visual_effect :blind_down, "post_wapper_#{post.id}"
        }
      end
      
      return
    end
    
    render :text=>"转晒成功"
    #render :action=>'success'
  end
  
  
  def delete_post
    post = Post.find(params[:id])
    Post.delete_post(params[:id],@user)
    Mms::Score.trigger_event(:delete_post, "垃圾记录被清理", -2, 1, {:user => post.user})
    render :text=>'删除成功'
  end
  
  def delete_angle_post
    AnglePost.delete_angle_post(params[:id],@user)
    render :text=>'{success:1}'
  end
  
  ################# angle comments ############################
  
  def list_angle_comments
    @post = AnglePost.find(params[:id])
  end
  
  def create_angle_comment
    @post = AnglePost.find(params[:id])
    @comment = AngleComment.create_angle_comment(params,@user,@post)
    @comment = AngleComment.new if @comment.errors.empty?
    redirect_to :action=>'list_angle_comments',:id=>@post.id
  end
  
  def delete_angle_comment
    @post = AngleComment.delete_angle_comment(params[:id],@user)
    return render_404 unless @post
    render :text=>'{success:1}'
  end
  
  #################### follow ########################
  
  def create_follow_user
    @to_follow_user = User.find(params[:id])
    result = FollowUser.create_follow_user(@to_follow_user,@user)

    #关注生成消息提醒
    CommentAtRemind.create(:tp=>"follow", :user_id=>params[:id], :author_id=>@user.id, :comment_id=>@user.id) rescue nil
    if result == 'overload'
      render :text=>'超出上限' and return false
    end
    render :text=>'<img src="/images/icons/follow_success.gif"/>'
  end
  
  def create_follow_user2
    @to_follow_user = User.find(params[:id])
    result = FollowUser.create_follow_user(@to_follow_user,@user)

    #关注生成消息提醒
    CommentAtRemind.create(:tp=>"follow", :user_id=>params[:id], :author_id=>@user.id, :comment_id=>@user.id) rescue nil
    if result == 'overload'
      render :text=>'超出上限' and return false
    end
    render :text=>'<img src="/images/ygz.png"/>'
  end
  
  def delete_follow_user
    @to_follow_user = User.find(params[:id])
    FollowUser.delete_follow_user(@user,@to_follow_user)
    render :text=>APP_CONFIG['success_cancel']
  end
  
  def delete_fans_user
    @fans_user = User.find(params[:id])
    FollowUser.delete_follow_user(@fans_user,@user)
    render :text=>APP_CONFIG['success_cancel']
  end
  
  def change_follows
    if params[:tp]=='invite'
      @users = User.find(:all,:limit=>params[:limit],:conditions=>['tp>0 and id<>? and (invite_user_id=? or invite_tuan_user_id=?)',@user.id,@user.invite_user_id,@user.invite_tuan_user_id],:order=>'users.posts_count desc')
    elsif params[:tp]=='age'
      @users=User.find_maybe_users(@user,'age',{:limit=>params[:limit],:order=>'rand()',:age_id=>@user.age.id})
    else
      @users=User.find_maybe_users(@user,params[:tp],{:limit=>params[:limit],:order=>'rand()'})
    end
    render :partial=>"/account/follow_user",:locals=>{:users=>@users}
  end
  
  #################### favorite #######################
  
  def list_favorites
    @post = Post.find(params[:id])
  end
  
  def list_event_users
    @post = Post.find(params[:id])
    @event = @post.event
    @event_users = @event.event_users
  end
  
  def create_favorite_post
    @post = Post.find(params[:id])
    @favorite_post = FavoritePost.create_favorite_post(@post,@user,params)
    @favorite_post = FavoritePost.new if @favorite_post.errors.empty?
    
    if @post.from == 'column'
        @post.column_chapter.column_book.favorites += 1
        @post.column_chapter.column_book.save
    end
    render :action=>'list_favorites'
  end
  
  def delete_favorite_post
    FavoritePost.delete_favorite_post(params,@user)
    render :text=>APP_CONFIG['success_cancel']
  end  
  
  def create_favorite_tag 
    @tag = Tag.find(params[:id])
    FavoriteTag.create_favorite_tag(@tag,@user)
    render :action=>'result_favorite_tag'
  end
  
  def delete_favorite_tag
    @tag = Tag.find(params[:id])
    FavoriteTag.find_by_tag_id_and_user_id(@tag.id,@user.id).destroy
    render :action=>'result_favorite_tag'
  end
  
  #################### post_recommend #######################
  
  def list_post_recommends
    @post = Post.find(params[:id])
  end
  
  def create_post_recommend
    @post = Post.find(params[:id])
    @post_recommend = PostRecommend.create_post_recommend(@post,@user,params)
    @post_recommend = PostRecommend.new if @post_recommend && @post_recommend.errors.empty?
    render :action=>'list_post_recommends'
  end
  
  def delete_post_recommend
    PostRecommend.delete_post_recommend(params,@user)
    render :text=>APP_CONFIG['success_cancel']
  end
  
  ################### gift ####################
  
  def set_private_gift
    @gift_get = GiftGet.find_by_id_and_send_user_id(params[:id],@user.id)
    @gift_get.is_private = true
    @gift_get.save
    render :text=>APP_CONFIG['success_hide']
  end
  
  ################### notify #####################
  
  def sms_notify_invite
    render :text=>'请先填写您的手机' and return false if @user.mobile.blank?
    user_profile = @user.user_profile
    user_actions = user_profile.user_actions.split('|')
    unless user_actions.include?('fetion_invite')
      user_actions << 'fetion_invite'
      user_profile.update_attributes(:user_actions=>user_actions.join('|'))
    end
    MamashaiTools::HttpUtil.send_fetion_invite(@user.mobile)
    render :text=>"<span>#{APP_CONFIG['success_sms_invite']}</span>"
  end
  
  
  ################# tuan_comments ############################
  
  def list_tuan_comments
    @tuan = Tuan.find(params[:id])
  end
  
  def create_tuan_comment
    @tuan = Tuan.find(params[:id])
    @comment = TuanComment.create_comment(params,@user)
    unless @comment.errors.empty?
      render :action=>'list_tuan_comments' and return false 
    end
    @comment = TuanComment.new if @comment.errors.empty?
    redirect_to :action=>'list_tuan_comments',:id=>@tuan.id
  end
  
  def delete_tuan_comment
    @tuan = TuanComment.delete_tuan_comment(params[:id],@user)
    return render_404 unless @tuan
    redirect_to :action=>'list_tuan_comments',:id=>@tuan.id,:hide_box=>true
  end
  
  
  # delete comment in home comments list
  def delete_post_tuan_comments
    Comment.delete_post_comment(params[:id],@user)
    render :text=>"<script>hide_box();Element.remove('comment_wapper_#{params[:id]}');</script>"
  end
  
  def create_reply_tuan_comment
    @post = Post.find(params[:id])
    @comment = Comment.create_comment(params,@user,@post)
  end
  
  #################### favorite_tuan #######################
  
  def list_favorite_tuans
    @tuan = Tuan.find(params[:id])
  end
  
  def create_favorite_tuan
    @tuan = Tuan.find(params[:id])
    @favorite_tuan = FavoriteTuan.create_favorite_tuan(@tuan,@user,params)
    render :text =>"您已收藏过此团购，不能再次收藏" and return if @favorite_tuan.new_record?()
    render :text=>"收藏成功"
  end
  
  def delete_favorite_tuan
    FavoriteTuan.delete_favorite_tuan(params,@user)
    render :text=>APP_CONFIG['success_cancel']
  end  
  
  def create_favorite_tag 
    @tag = Tag.find(params[:id])
    FavoriteTag.create_favorite_tag(@tag,@user)
    render :action=>'result_favorite_tag'
  end
  
  def delete_favorite_tag
    @tag = Tag.find(params[:id])
    FavoriteTag.find_by_tag_id_and_user_id(@tag.id,@user.id).destroy
    render :action=>'result_favorite_tag'
  end
  
  #  ################## forward tuan ##########################
  
  def new_forward_tuan
    @post = Post.new
    @tuan = Tuan.find(params[:id])
    @post.tuan = @tuan if @tuan
  end  
  
  def new_forward_gou
    @post = Post.new
    @gou = Gou.find(params[:id])
  end
  
  def create_forward_tuan
    post = Post.create_forward_tuan_post(params,@user)
    text = post.errors.empty? ? "转晒成功" : "转晒失败"
    render :text=>text
  end
  
  def create_forward_gou
    post = Post.create_forward_gou_post(params,@user)
    text = post.errors.empty? ? "转晒成功" : "转晒失败"
    render :text=>text
  end
  
  # ============== state machine ===============
  
  def state_index
    
  end
  
  def update_state
    case params[:instance][:class]
      when "TuanOrder"
      klass = TuanOrder
    end
    instance = klass.find(params[:instance][:id])
    instance.fire_events(params[:instance][:event].strip().to_sym)
    redirect_to params[:instance][:origin_url]
  end
  
  def new_vote
    @votes = Vote.find(:all, :conditions=>"user_id = #{@user.id}")
  end
  
  #创建一个投票
  def create_vote
    @vote = Vote.new(params[:vote])
    keys = params[:option].keys.collect{|key| 10000+key.to_i}.sort
    options = []
    for key in keys
      k = key - 10000
      options << params[:option][k.to_s] if params[:option][k.to_s] && params[:option][k.to_s].size > 0
    end
    @vote.options = options.join("&*")
    days = 90
    days = params[:days].to_i if params[:days] && params[:days].to_i > 0
    @vote.user_id = @user.id
    @vote.endtime = Time.new + days.days
    @vote.save
  end
  
  #选择某个投票
  def select_vote
    @vote = Vote.find(params[:vote_id])
    render :action=>"create_vote"
  end
  
  #进行一个投票
  def make_a_vote
    vote = Vote.find(params[:vote_id])
    for option in params[:option]
      election = VoteElection.new
      election.user_id = @user.id
      election.option = option
      election.vote_id = params[:vote_id]
      election.save
    end
    post = Post.new
    post.content = "我参与了投票【#{vote.title}】，投给“#{params[:option].join('，')}”这#{params[:option].size}个选项"
    post.user_id = @user.id
    post.from = "vote"
    post.from_id = vote.id
    post.save
    if params[:go_back] == "topic"
      render :partial=>"tag_vote", :locals=>{:vote => vote }
    else
      render :partial=>"post_vote", :locals=>{:post=>Post.find(params[:id])}
    end

  end

  def get_post_vote
    post = Post.find(params[:id])
    render :partial=>"post_vote", :locals=>{:post=>post}
  end
  
  #精彩推荐
  def add_recommand
    recommand = Recommand.find(:first, :conditions=>"t='#{params[:t]}' and t_id = #{params[:id]}")
    if !recommand
      recommand = Recommand.new
      recommand.t_id = params[:id]
      recommand.t = params[:t]
      recommand.save
      render :text=>"<img src='/images/icons/award_star_gold_3.png'>"
    else
      recommand.destroy
      render :text=>"<img src='/images/icons/award_star_add.png'>"
    end
    
  end
  
  def receive_coupon
    @coupon = Coupon.find(params[:id])
    @coupon.receive_present
    render :text=>@coupon.state_type
  end


##################  recommend hot topic to friends##########################
  def new_forward_hot_topic
    @post = Post.new
    @tag = Tag.find_by_id(params[:id])
    if @tag
      @post.content = "给大家推荐一个热门话题##{@tag.name}#！如果你也有兴趣，快来和我一起聊吧！#{hot_topics_url(@tag.name)} "
    end
  end

  def create_forward_hot_topic
    @post = Post.new(params[:post])
    Post.create_forward_hot_topic_post(@post.content,@user)
    render :action=>'success'
  end

  def hot_vote_top
    vote = Vote.find(params[:id])
    render :partial => "tag_vote",:locals=>{:vote=>vote}
  end

  def create_user_tag
    tag_name = params[:tag_name]
    unless tag_name.blank?
      tag = Tag.create_tag_from_post(tag_name)
      @user.tags  << tag  unless @user.tags.include?(tag)
    end
    render :partial => "topic_user_custom_tags"
  end
  
  def clap_users
    @claps = Clap.find(:all, :conditions=>"tp='post' and tp_id = #{params[:id]}", :group=>"user_id")
  end

  def add_post_rates
    post = Post.find(params[:id])
    post.update_attribute :post_rates_count, params[:count]
    if params[:count].to_i > 0
      post.user.add_level_score(10, "小编推荐热点")
    end
    render :text=>"ok"
  end

  #记录私有
  def set_private
    post = Post.find(params[:id])
    post.is_private = true
    post.save
    render :text=>"ok"
  end

  #用户进入私有黑名单
  def private_block
    user = User.find(params[:id])
    if user
      block = Blockpublic.new
      block.user_id = user.id
      block.name = user.name
      block.save
      render :text=>"已进入私有黑名单"
    else
      render :text=>"找不到用户"
    end
  end

  #用户进入记录黑名单
  def write_block
    user = User.find(params[:id])
    if user
      block = Blockname.new
      block.user_id = user.id
      block.name = user.name
      block.save
      render :text=> "已进入记录黑名单"
    else
      render :text=> "找不到用户"
    end
  end

end
