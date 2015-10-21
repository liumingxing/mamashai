class Mms::UsersController < Mms::MmsBackEndController
  
  def index
    @mms_users = Mms::User.paginate :page => params[:page], :per_page => 30, :order => 'id asc'
  end
  
  def new
    @keys = YAML.load_file(File.join(::Rails.root.to_s, 'config', 'permission.yml')).keys
    @user = Mms::User.new
  end
  
  def create
    if params[:id].blank? or params[:mms_user][:name].blank?
      flash[:mms_user] = "操作失败，请检查一下是否填写了真实姓名！"
      redirect_to :action => 'list_users'
    else
      user=::User.find(params[:id])
      mms_user = Mms::User.new(params[:mms_user])
      mms_user.copy_columns_from_users(user)
      mms_user.save
      redirect_to :action => 'list_users',:success=>"success" and return
    end
    
  end
  
  def edit
    @user = Mms::User.find(params[:id])
  end
  
  def update
    #case request.method
    #when :put
      @user = Mms::User.find(params[:id])
      @user.name = params[:mms_user][:name] if params[:mms_user][:name]
      @user.power = params[:mms_user][:power] if params[:mms_user][:power]
      @user.password = Mms::User.encrypt(params[:mms_user][:password]) unless params[:mms_user][:password].empty?
      @user.save(:validate=>false)
    #end
    redirect_to params[:path] and return if params[:path]
    redirect_to :action => 'index'
  end
  
  def destroy
    case request.method
    when :delete
      @user = Mms::User.find(params[:id])
      @user.destroy
    end
    redirect_to :action => 'index'
  end
  
  def show
    @user = Mms::User.find(params[:id])
    @power = YAML.load_file(File.join(::Rails.root.to_s, 'config', 'permission.yml'))[@user.power]
  end
  
  
  ##########signup#########
  def list_user_signups
    @search_email = params[:search_email] unless params[:search_email].blank?
    if @search_email
      @users = ::User.paginate(:per_page => 25,:conditions=>["is_verify=? and email=?",false,@search_email],:page => params[:page],:order => "id desc")      
    else
      @users = ::User.paginate(:per_page => 25,:conditions=>["is_verify=?",false],:page => params[:page],:order => "id desc")
    end
  end
  
  def delete_user_signup
    @user = ::User.find(params[:id])
    email = @user.email
    if @user.destroy
      flash[:notice]=email+"删除成功"
    else
      flash[:notice]=email+"删除失败"
    end
    redirect_to :action => 'list_user_signups'
  end
  
  def list_users
    return render_404 unless @mms_user
    if params[:keyword].blank?
      @users = ::User.paginate :conditions=>['id=?',params[:id]],:order => "id desc", :page=>params[:page]
    else
      @users = User.__elasticsearch__.search("name:#{params[:keyword]}").per_page(10).page(params[:page]).records

      #@users = ::User.search params[:keyword], :order => "id desc", :page=>params[:page], :per_page=>10
    end
    @mms_users = Mms::User.all
  end
  
  def hide_user
    return render_404 unless @mms_user
    u=ActiveRecord::Base::User.find(params[:id])
    User.hide_user(params[:id])
    redirect_to :action => 'list_orgs' and return if u.is_org?
    redirect_to :action => 'list_users' 
  end
  
  def user_wing
    return render_404 unless @mms_user
    if u=ActiveRecord::Base::User.find(params[:id])
      u.tp == 4 ? u.tp=1 : u.tp=4 
      u.save(:validate=>false)
    end
    redirect_to :action => 'list_users' 
  end
  
  def user_angel
    return render_404 unless @mms_user
    if u=ActiveRecord::Base::User.find(params[:id])
      u.tp == 2 ? u.tp=1 : u.tp=2 
      u.save(:validate=>false)
    end
    redirect_to :action => 'list_users' 
  end
  
  
  ##########org############
  def list_orgs
    @users=ActiveRecord::Base::User.search(params[:keyword]).org.paginate :page=>params[:page]
  end
  
  def user_certificate
    @u=ActiveRecord::Base::User.find(params[:id])
  end
  
  def set_certificate
    return render_404 unless @mms_user
    if u=ActiveRecord::Base::User.find(params[:id])
      u.tp == 3 ? u.tp=1 : u.tp=3 
      u.remark = params[:remark]
      u.save(:validate=>false)
    end
    redirect_to :action => 'list_orgs' and return if u.is_org?
    redirect_to :action => 'list_users' 
  end
  
  def set_admin
    user = ::User.find(params[:id])
    mms_user = Mms::User.new
    mms_user.name = user.name
    mms_user.username = user.email
    mms_user.password = user.password
    mms_user.save
    flash[:notice] = "设为管理员成功"
    redirect_to :action=>"index"
  end

  def delete_user
    user = ::User.find(params[:id])
    posts = Post.find_all_by_user_id user.id
    posts.each do |p|
      Post.__elasticsearch__.client.delete(:index=>'posts', :id=>p.id, :type=>"post")
      p.destroy
    end
    as = ArticleComment.find_all_by_user_id user.id
    as.each do |p|
      p.destroy
    end
    CommentAtRemind.delete_all "author_id=#{user.id}"
    Blackname.create :ip => user.last_login_ip rescue nil

    Rails.cache.delete("blacknames")

    Blacksid.create :sid=>user.sid, :remark=>user.name if user.sid.to_s.size > 5
    user.destroy
    redirect_to :action=>"list_users"
  end

  def reset_password
    user = ::User.find(params[:id])
    user.password = '9c39c056165ec64d8fddb57c6d7e560b'
    user.save
    flash[:notice] = "重置密码成功"
    redirect_to :action=>"list_users"
  end

  def block
    user = ::User.find(params[:id])
    if user
      block = Blockname.new
      block.user_id = user.id
      block.name = user.name
      block.save
    end
    flash[:notice] = "进入黑名单成功"
    redirect_to :action=>"list_users"
  end

  def block_star
    user = ::User.find(params[:id])
    if user
      block = Blockstar.new
      block.user_id = user.id
      block.name = user.name
      block.save
    end
    flash[:notice] = "进入黑名单成功"
    redirect_to :action=>"list_users"
  end

  def block_public
    user = ::User.find(params[:id])
    if user
      block = Blockpublic.new
      block.user_id = user.id
      block.name = user.name
      block.save
    end
    flash[:notice] = "进入私有黑名单成功"
    redirect_to :action=>"list_users"
  end

  def list_block
    params[:tp] ||= "private"
    if params[:tp] == "private"
      @blocks = Blockpublic.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
    elsif params[:tp] == "star"
      @blocks = Blockstar.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
    elsif params[:tp] == "write"
      @blocks = Blockname.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
    end
  end

  def remove_block
    params[:tp] ||= "private"
    if params[:tp] == "private"
      Blockpublic.destroy(params[:id])
    elsif params[:tp] == "star"
      Blockstar.destroy(params[:id])
    elsif params[:tp] == "write"
      Blockname.destroy(params[:id])
    end
    redirect_to :action=>"list_block", :tp=>params[:tp]
  end

  def comment_block
    @blocks = Blockcomment.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
  end

  def add_comment_block
    users1 = ::User.find(:all, :conditions=>["name = ?", params[:user_name1]])
    users2 = ::User.find(:all, :conditions=>["name = ?", params[:user_name2]])
    for u1 in users1
      for u2 in users2
        Blockcomment.create(:user_id1 => u1.id, :user_id2=>u2.id, :user_name1=>u1.name, :user_name2=>u2.name)
      end
    end

    redirect_to :action=>"comment_block"
  end

  def delete_comment_block
    Blockcomment.destroy(params[:id])
    redirect_to :action=>"comment_block"
  end

  def make_score
    @user = User.find(params[:id])
  end

  def update_make_score
    user = ::User.find(params[:id])
    user.score += params[:count].to_i
    user.save(:validate=>false)
    ScoreEvent.create(:event=>params[:reason], :score=>params[:count], :user_id=>params[:id], :total_score=>user.score, :unit=>1, :event_description=>params[:reason])
    flash[:notice] = "返豆成功"
    redirect_to :action=>"make_score", :id=>params[:id]
  end

  def list_score
    if params[:keyword] && params[:keyword].length > 0
      @users = ::User.search params[:keyword], :page=>params[:page], :per_page=>20
    elsif params[:id] && params[:id].length > 0
      @users = ::User.paginate :conditions=>"id = #{params[:id]}", :page=>params[:page], :per_page=>20
    else
      @users = ::User.paginate :order=>"score desc", :page=>params[:page], :per_page=>20, :total_entries=>100
    end
  end

  def score_detail
    @events = ScoreEvent.paginate(:conditions=>"user_id=#{params[:id]} and score != 0", :order=>"id desc", :page=>params[:page], :per_page=>20)
  end

  def red_packets
    @packets = RedPacket.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
  end

  def packet_succ
    packet = RedPacket.find(params[:id])
    packet.status = '成功'
    packet.save

    if packet.user.score < packet.score
      flash[:notice] = "晒豆不足" 
      redirect_to :action=>"red_packets", :page=>params[:page]
      return;
    end
    
    packet.user.score -= packet.score
    packet.user.save(:validate=>false)
    packet.user.reload
    ScoreEvent.create(:event=>'red_packet', :score=>0-packet.score, :user_id=>packet.user_id, :total_score=>packet.user.score, :unit=>1, :event_description=>"晒豆换支付宝红包")

    #Mms::Score.trigger_event(:red_packet, "晒豆换支付宝红包", 0-packet.score, 1, {:user => packet.user})

    message = {}
    message[:message_post] = {}
    message[:message_post][:user_name] = packet.user.name
    message[:message_post][:content] = "你的支付宝红包已到账，可以到妈妈晒贴心购消费了，请注意红包有效期是7天，过期就失效了。如果您喜欢您买的商品，希望能给个好评哦！"
    message_post=MessagePost.create_message_post(message,User.find(431))
    unless message_post.errors.empty?
      flash[:notice]+="发送私信时发生错误。\n"
    end

    flash[:notice] = "扣豆成功"
    redirect_to :action=>"red_packets", :page=>params[:page]
  end

  def set_email
    user = ::User.find_by_id(params[:id])
    if user
      user.email = params[:email]
      user.password = MamashaiTools::TextUtil.md5("mamashai")
      user.save
    end
    flash[:notice] = "重设密码成功"
    redirect_to :action=>"list_users"
  end
end
