class Api::FriendshipsController < Api::ApplicationController
    before_filter :authenticate!, :except=>[:show]
    # ==返回两个用户关注关系的详细情况
    #   [路径]: friendships/show
    #   [HTTP请求方式]: GET
    #   [URL]: http://your.api.domain/friendships/show.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - source_id  源用户UID, 如果为空， 则使用当前用户ID
    # - target_id  要判断的目标用户ID （必填）
    #
    # ====示例
    #   curl -u "username:password"
    #   "http://your.api.domain/friendships/show.json?source=appkey&source_id=7702&target_id=7701"
    #
    # ====注意
    #   如果用户已登录，此接口将自动使用当前用户ID作为source_id。但是可强制指定source_id来查询关注关系。
    #   如果源用户或目的用户不存在，则返回error
    #
    # ====返回json字段
    # - id 用户ID
    # - name  用户昵称
    # - following 关注
    # - followed_by 被关注
    #
    def show
        if params[:source_id].to_i == 0
            result = {
              :source=>{
                :following => false,
                :followed_by => false
              },
              :target=>{
                :following => false,
                :followed_by => false
              }
            }
            render :json=>result and return 
        end
        source_user = User.find(params[:source_id]) rescue @user
        target_user = User.find(params[:target_id])
        attr = FollowUser.check_follow(source_user, target_user)
        render :json=>attr
    end

    # ==关注一个用户。关注成功则返回关注人的资料，目前的最多关注2000人。
    #   [路径]: friendships/create
    #   [HTTP请求方式]: POST
    #   [URL]: http://your.api.domain/friendships/create.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - :id  要关注的用户ID
    #
    # ====示例
    #   curl -u "username:password" -d "id=7701"
    #   "http://your.api.domain/friendships/create.json?source=appkey"
    #
    # ====注意
    # - 如果目的用户不存在，则返回error
    # - 如果关注人数超过最高限制2000，则返回overload
    # - 操作成功则返回ok
    #
    def create
        target_user = User.find(params[:id])
        result = FollowUser.create_follow_user(target_user,@user)

        CommentAtRemind.create(:tp=>"follow", :user_id=>params[:id], :author_id=>@user.id, :comment_id=>@user.id) rescue nil
        render :text => result and return if result == 'overload'
        render :text=>"ok"
    end

    # ==取消对某用户的关注。 
    #   [路径]: friendships/destroy
    #   [HTTP请求方式]: POST/DELETE
    #   [URL]: http://your.api.domain/friendships/destroy.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - :id  要关注的用户ID
    #
    # ====示例
    #   curl -u "username:password" -d "id=7701"
    #   "http://your.api.domain/friendships/destroy.json?source=appkey"
    #
    # ====注意
    # - 如果目的用户不存在，则返回error
    # - 操作成功则返回ok
    #
    def destroy
        to_follow_user = User.find(params[:id])
        FollowUser.delete_follow_user(@user,to_follow_user)
        render :text=>"ok"
    end

end