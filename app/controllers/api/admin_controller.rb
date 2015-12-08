class Api::AdminController < Api::ApplicationController
  before_filter :authenticate!
  
  def identify
    if @user.tp == 4
      render :text=>"yes"
    else
      render :text=>"对不起，你不是管理员"
    end
  end

  def recommand
    render :text=>"对不起你没有权限" and return if @user.tp != 4

    post = Post.find(params[:id])
    if params[:score].to_i < 1000
      post.update_attribute :post_rates_count, params[:score]
    else    #置顶
      post.update_attribute :post_rates_count, Time.new.to_i
    end
    if params[:score].to_i > 0
      post.user.add_level_score(10, "小编推荐热点")
    end

    if params[:score].to_i > 0
      render :text=>"推荐热点成功"
    else
      render :text=>"设置成功"
    end
  end

  def delete_post
    render :text=>"对不起你没有权限" and return if @user.tp != 4

    post = Post.find(params[:id])
    Post.delete_post(params[:id], @user)

    Mms::Score.trigger_event(:delete_post, "垃圾记录被清理", -2, 1, {:user => post.user})
    
    render :text=>'删除记录成功'
  end

  def private_post
    render :text=>"对不起你没有权限" and return if @user.tp != 4

    post = Post.find(params[:id])
    post.is_private = true
    post.save
    render :text=>"记录成功私有"
  end

  def delete_user
    render :text=>"对不起此功能已被停止" and return if @user.id != 270
    render :text=>"对不起你没有权限" and return if @user.tp != 4

    user = User.find(params[:id])
    Post.__elasticsearch__.client.delete(:index=>'users', :id=>user.id, :type=>"user") rescue nil
    posts = Post.find_all_by_user_id user.id
    posts.each do |p|
      Post.__elasticsearch__.client.delete(:index=>'posts', :id=>p.id, :type=>"post") rescue nil
      p.destroy
    end
    as = ArticleComment.find_all_by_user_id user.id
    as.each do |p|
      p.destroy
    end
    CommentAtRemind.delete_all "author_id=#{user.id}"
    Blackname.create :ip => user.last_login_ip rescue nil
    Rails.cache.delete("blacknames")
    user.destroy
    render :text=>"删除用户成功"
  end

  def delete_comment
    render :text=>"对不起你没有权限" and return if @user.tp != 4
    if params[:tp] == "article"
      comment = ArticleComment.find(params[:id])
      comment.destroy
    else
      comment = Comment.find(params[:id])
      comment.destroy
    end
    
    render :text=>"删除评论成功"
  end

  #私有黑名单
  def black_private
    render :text=>"对不起你没有权限" and return if @user.tp != 4
    user = User.find(params[:id])
    if user
      block = Blockpublic.where(user_id: user.id).try(:first)
      if block.present?
        block.touch
      else
        block = Blockpublic.new
        block.user_id = user.id
        block.name = user.name
        block.save
      end
    end
    render :text=>"进入私有黑名单成功"
  end

  #记录黑名单
  def black_write
    user = User.find(params[:id])
    if user
      block = Blockname.where(user_id: user.id).try(:first)
      if block.present?
        block.touch
      else
        block = Blockname.new
        block.user_id = user.id
        block.name = user.name
        block.save
      end
    end
    render :text=>"进入记录黑名单成功"
  end

  #星星榜黑名单
  def black_xxb
    user = ::User.find(params[:id])
    if user
      block = Blockstar.where(user_id: user.id).try(:first)
      if block.present?
        block.touch
      else
        block = Blockstar.new
        block.user_id = user.id
        block.name = user.name
        block.save
      end
    end
    render :text=> "进入星星榜黑名单成功"
  end
end