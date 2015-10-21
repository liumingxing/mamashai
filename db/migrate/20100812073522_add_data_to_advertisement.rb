class AddDataToAdvertisement < ActiveRecord::Migration
  def self.up
    
    content = '<div id="s3slider" style="width: 561px; margin: 20px auto;">
                  <ul id="s3sliderContent">
                        <li class="s3sliderImage" style="display: none;"> 
                      <a title="妈妈晒团购" href="/tuan/mama/1595?ad_keyword=152">
                        <img src="/images/ads/home_tuan_3.jpg?1281585907" alt="Home_tuan_3">
                      </a>
                      <span style="display: none;"></span>
                    </li>
                    <li class="s3sliderImage" style="display: list-item;"> 
                      <a title="妈妈晒团购" href="/tuan/mama/1226?ad_keyword=152">
                        <img src="/images/ads/home_tuan_4.jpg?1281586207" alt="Home_tuan_4">
                      </a>
                      <span style="display: inline;"></span>
                    </li>
                        <div class="clear s3sliderImage"></div>
                    </ul>
                </div>
                <script type="text/javascript">
                  jQuery(function() {
                     jQuery("#s3slider").s3Slider({
                        timeOut: 6000
                     });
                  }); 
                </script>
                <script src="/javascripts/controllers/event/s3slider.js"></script>'
    Advertisement.create(:position => 1, :description => "我的首页", :content => content)
    
    content = '<a title="晒心得，领取ipad和亲子衫" href="/event/eproduct"><img alt="晒心得，领取ipad和亲子衫" src="/images/ads/login_bg_2.gif"></a>'
    Advertisement.create(:position => 2, :description => "未登录首页、找回密码", :content => content)
    
    content = '<a title="晒心得，领取ipad和亲子衫" href="/account/signup/212"><img src="/images/ads/space_bg_2.jpg" alt="晒心得，领取ipad和亲子衫"></a>'
    Advertisement.create(:position => 3, :description => "个人空间", :content => content)
    
    content = '<a title="天天送喜洋洋公仔套装 陪你过暑假" href="/event/xiyangyang"><img src="/images/ads/event_bg_1.gif"></a>'
    Advertisement.create(:position => 4, :description => "活动首页", :content => content)
    
  end

  def self.down
     Advertisement.find_by_position(1).destroy
     Advertisement.find_by_position(2).destroy
     Advertisement.find_by_position(3).destroy
     Advertisement.find_by_position(4).destroy
  end

end
