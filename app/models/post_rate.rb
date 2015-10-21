class PostRate < ActiveRecord::Base
  #belongs_to :post, :counter_cache => true
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :post_id
  validates_presence_of :rate
 
  ################## create ####################
  
  def self.create_post_rate(params,post,user)
    post_rate = PostRate.find_by_post_id_and_user_id(post.id,user.id)
    post_rates_count = post.post_rates_count
    if post_rate
      post_rate.update_attributes(:rate=>params[:rate])
    else
      post_rate = PostRate.create(:user_id=>user.id,:post_id=>post.id,:rate=>params[:rate])
      post_rates_count += 1
    end
    sum = PostRate.find(:all,:conditions=>['post_id=?',post.id]).sum{|item| item.rate * 2 }
    post.update_attributes(:rate=>(sum/post_rates_count*10).round/10.0)
    
    post_user = User.find(post.user_id)
    if post_user.is_org
      post_rate.post_user_id = post_user.id
      post_rate.save
      org_post_rates = PostRate.find(:all,:conditions=>['post_user_id=?',post_user.id])
      sum = org_post_rates.sum{|item| item.rate * 2 }
      rates_num  = org_post_rates.length
      post_user.update_attributes(:rate=>(sum/rates_num*10).round/10.0,:rates_num=>rates_num)
    end
    
    return post_rate
  end
  
end
