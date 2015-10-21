class Mms::MessagesController < Mms::MmsBackEndController
  
  def messages
    @message_post = MessagePost.new
    @is_sys = true
  end
  
  def messages_import_vip_user
    @message_post = MessagePost.new
    @message_post.user_name = ::User.find(:all,:conditions=>['tp=2']).collect{|u| u.name}.join(';')
    @is_sys = false
    render :action=>'messages'
  end
  
  def messages_import_hide_user
    @message_post = MessagePost.new
    @message_post.user_name = ::User.find(:all,:conditions=>['tp=4']).collect{|u| u.name}.join(';')
    @is_sys = false
    render :action=>'messages'
  end
  
  def send_sys_messages
    @is_sys = params[:is_sys]
    if @is_sys
      @sys_topic = MessageTopic.find_sys_topic
      @message_post = MessagePost.create_sys_post(params,@sys_topic)  
      unless @message_post.errors.empty?
        render :action=>'messages' and return false
      end
    else
      user_names = params[:message_post][:user_name].split(';')
      user_names.each do |user_name|
        params[:message_post][:user_name] = user_name
        @message_post = MessagePost.create_message_post(params,::User.find(User.mms_user_id))
        unless @message_post.errors.empty?
          render :action=>'messages' and return false
        end
      end
    end 
    redirect_to :action => 'messages',:success=>'success'
  end
end
