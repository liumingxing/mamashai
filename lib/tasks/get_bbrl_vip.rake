require 'mamashai_tools/taobao_util'
require 'open-uri'
include MamashaiTools

namespace :mamashai do
  desc "获取宝宝日历VIP"
  task :get_bbrl_vip  => [:environment] do
    #设置豆豆换的状态
    ddhs = Ddh.all
    for ddh in ddhs
      ddh.set_status
      ddh.save
    end

    vip_user_ids = BbrlVip.find(:all).collect{|v| v.user_id}
    posts = Post.bbrl.find(:all, :limit=>4, :select=>'count(id) as count, posts.*', :conditions=>"user_id not in (#{vip_user_ids.join(',')}) and  created_at > '#{Time.new.ago(7.days).at_beginning_of_day().to_s(:db)}' and user_id != 102 and user_id != 228 and user_id != 76145 and user_id != 103421 and user_id != 270 and user_id != 7899 and user_id != 82204 and user_id != 83401", :group=>'user_id', :order=>'sum(comments_count) desc')
    BbrlVip.delete_all
    p posts
    for post in posts
      vip = BbrlVip.new
      vip.user_id = post.user_id
      vip.user_name = post.user.name
      vip.week_posts_count = post['count']
      vip.save
    end

    #清空tongji表中的过期数据
    Tongji.delete_all("created_at < '#{Time.new.ago(1.days).to_s(:db)}'")

    #for product in TaoProduct.find(:all)
    #  if product.url_mobile.to_s.include?('s.click.taobao.com')
    #    res = MamashaiTools.taobao_call("taobao.tbk.items.detail.get", {"fields"=>"num_iid,title,nick,pic_url,price,click_url,commission,commission_rate,commission_num,commission_volume,shop_click_url,seller_credit_score,item_location,volume,item_url", "num_iids"=>product.iid.to_s})
    #    p res
    #    if res['tbk_items_detail_get_response'] && res['tbk_items_detail_get_response']['total_results'] == 0
    #      product.cancel = true
    #    else
    #      product.price = res['tbk_items_detail_get_response']['tbk_items']['tbk_item'][0]['price']
    #      cancel = false
    #    end
    #    product.save

    #    p product.id
    #  end
    #end
  end
end