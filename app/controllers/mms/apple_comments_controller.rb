require 'score'

class Mms::AppleCommentsController < Mms::MmsBackEndController
  def index
    list
    render :action => 'list'
  end

  def search
    @apple_comments = AppleComment.paginate :conditions=>"apple_comments.name like '%#{params[:name]}%' or apple_comments.name like '%#{URI.encode(params[:name])}%' or users.name = '#{params[:name]}'", :page=>params[:page], :per_page => 10, :order=>"apple_comments.id desc", :joins=>"left join users on users.id = apple_comments.user_id"
    render :action=>"list"
  end

  def list
    @apple_comments = AppleComment.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @apple_comment = AppleComment.find(params[:id])
  end

  def new
    @apple_comment = AppleComment.new
  end

  def create
    @apple_comment = AppleComment.new(params[:apple_comment])
    if @apple_comment.save
      flash[:notice] = 'AppleComment was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @apple_comment = AppleComment.find(params[:id])
  end

  def update
    @apple_comment = AppleComment.find(params[:id])
    if @apple_comment.update_attributes(params[:apple_comment])
      flash[:notice] = 'AppleComment was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    AppleComment.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def make_score
    comment = AppleComment.find(params[:id])
    comment.score = 20
    comment.save

    #上限给3次
    if ScoreEvent.count(:conditions=>"event = 'make_appstore_comment' and user_id = #{comment.user.id} and created_at > '#{Time.new.ago(20.days)}'") >= 3
      redirect_to :action=>"list", :page=>params[:page]
      return
    end

    Mms::Score.trigger_event(:make_appstore_comment, "在应用商店中给好评", 20, 1, {:user => comment.user})

    message = {}
    message[:message_post] = {}
    message[:message_post][:user_name] = comment.user.name
    message[:message_post][:content] = "亲，感谢您的好评，我们给您增加了20个晒豆。让我们在育儿的道路上一起成长吧。"
    message_post=MessagePost.create_message_post(message,User.find(431))
    unless message_post.errors.empty?
      flash[:notice]+="发送私信时发生错误。\n"
    end
    
    #MamashaiTools::ToolUtil.push_aps(comment.user_id, "感谢您的好评，我们给您增加了50个晒豆")

    redirect_to :action=>"list", :page=>params[:page]
  end

  def capture
    @captures = ZhantingCapture.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
  end

  def album_score
    user = User.find(params[:id])
    Mms::Score.trigger_event(:join_share_album, "参加分享时光轴活动", 10, 1, {:user => user})
    render :text=>"ok"
  end

  def baba_score
    user = User.find(params[:id])
    Mms::Score.trigger_event(:join_share_baba, "参与爸爸在这儿活动", 15, 1, {:user => user})
    render :text=>"ok"
  end
end
