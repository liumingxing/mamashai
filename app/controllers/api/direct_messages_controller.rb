class Api::DirectMessagesController < Api::ApplicationController
    before_filter :authenticate!

    before_filter :check_block, :only=>%w(new)

    def check_block
        if Blockname.find_by_user_id(@user.id)
          render :text=>"对不起，操作失败！"
          return false;
        end
    end

    # ==获取当前用户最新私信列表
    #   [路径]: direct_messages/messages
    #   [HTTP请求方式]: GET
    #   [URL]: http://your.api.domain/direct_messages/messages.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - count  指定每页返回的记录条数。默认值10
    # - page  页码,默认是1。
    #
    # ====示例
    #   curl -u "username:password"
    #   "http://your.api.domain/direct_messages/messages.json?source=appkey&count=5&page=2&id=12212"
    #
    def messages
      #messages = MessagePost.paginate(:all, 
      #  :conditions=>["(message_posts.message_user_id=:user_id or message_posts.user_id = :user_id) and message_topics.user_id = :user_id and message_topics.id=:topic_id", {:user_id=>@user.id, :topic_id=>params[:id]}], 
      #  :joins=>:message_topic, :page=>params[:page]||1, :per_page=>params[:count]||10, :order=>"message_posts.created_at desc", :include=>[:user, :message_user])
      
      
      message_topic = MessageTopic.find(params[:id])
      if params[:cond]
        params[:cond] << "message_posts.created_at > '#{@user.created_at}'"
      else
        params[:cond] = "message_posts.created_at > '#{@user.created_at}'"
      end
      message_posts = message_topic.find_message_posts(params)
      
      render :json=>message_posts
    end
    
    # ==发送一条私信，请求必须使用POST方式提交。
    #   [路径]: direct_messages/new
    #   [HTTP请求方式]: POST
    #   [URL]: http://your.api.domain/direct_messages/new.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - name   私信接收方昵称。(必选)
    # - text  要发送的消息内容。(必选)
    #
    # ====示例
    #   curl -u "username:password" -d "username=琳琳妈&text=今天天气不错"
    #   "http://your.api.domain/direct_messages/new.json?source=appkey"
    #
    # ====注意事项
    #   发送成功将返回ok，失败返回error
    # 
    def new
        message = {
          :message_post=>{
            :content => URI.decode(params[:text]),
            :user_name => URI.decode(params[:name])
          }
        }
        message_post = MessagePost.create_message_post(message,@user)
        if message_post.errors.blank?
            render :text=>'ok'
        else
            render :text=>'error'
        end
    end

    # ==获取当前用户最新私信列表
    #   [路径]: direct_messages/user_timeline
    #   [HTTP请求方式]: GET
    #   [URL]: http://your.api.domain/direct_messages/user_timeline.json
    #   [是否需要登录]： true
    #
    # ====参数
    # - source 申请应用时分配的AppKey，调用接口时候代表应用的唯一身份。
    # - count  指定每页返回的记录条数。默认值10
    # - page  页码,默认是1。
    #
    # ====示例
    #   curl -u "username:password"
    #   "http://your.api.domain/direct_messages/user_timeline.json?source=appkey&count=5&page=2"
    #
    def index
      params[:page] ||= 1
      params[:per_page] = params[:count]||10
      message_topics = MessageTopic.find_message_topics(@user,params)
      message_topics = message_topics.delete_if{|topic|
        topic.is_sys && topic.message_posts.size > 0 && topic.message_posts.last.created_at < @user.created_at
      }


      render :text=>"null" and return if message_topics.size == 0
      render :json=>message_topics
    end

    def destroy
    	message = MessageTopic.find_by_id_and_user_id(params[:id],@user.id)
    	if message && !message.is_sys && message.destroy
	       render :text => 'ok' 	
    	else
 	       render :text => 'error'
    	end
    end

    def destroy2
      message = MessageTopic.find_by_id_and_user_id(params[:id],@user.id)
      render :text=>"无法删除此私信" and return if !message
      render :text=>"系统私信无法删除" and return if message.is_sys
      if message.destroy
        render :text=>"删除私信成功"
      else
        render :text=>"删除私信成功"
      end
    end
end
