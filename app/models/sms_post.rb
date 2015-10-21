class SmsPost < ActiveRecord::Base
  
  def self.create_sms_post(params)
    big_sms = SmsPost.find_by_id(58)
    unless (big_sms && big_sms.stxt == params[:stxt])
      sms_post = SmsPost.create(:sid=>params[:sid],:sno=>params[:sno],:stxt=>params[:stxt],:stime=>params[:stime])
      ActiveRecord::Base.transaction do
        user = User.find_by_mobile(sms_post.sno)
        if user 
          SmsPost.create_user_sms_post(sms_post,user)
        else
          SmsPost.bind_mobile(sms_post)
        end
      end
    end
  end
  
  def self.create_user_sms_post(sms_post,user)
    txt = sms_post.stxt 
    post_params = {:post=>{:content=>txt,:user_id=>user.id,:mobile_tp=>1,:created_at=>sms_post.stime.to_s}}
    post = Post.create_post(post_params,user)
    sms_post.post_id = post.id
    sms_post.save
    Mms::Score.trigger_event(:create_mobile_post, "用短信发布微博", 1, 1, {:cond => :by_per_day, :user => @user})
  end
  
  def self.bind_mobile(sms_post)
    user_profile = UserProfile.find_by_bind_mobile(sms_post.sno)
    if user_profile and user_profile.rand_code == sms_post.stxt
      user = user_profile.user
      user.update_attributes(:mobile=>user_profile.bind_mobile)
    end
  end
  
end
