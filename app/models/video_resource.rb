class VideoResource < ActiveRecord::Base
  belongs_to :video_category
  # attr_accessible :title, :body
  upload_column :logo ,:process => '1000x1000', :versions => {:thumb160 => "c160x98", :thumb320 => "c320x196", :thumb640 => "c640x392"}, :store_dir=>proc{|resource, file| "video_resource/#{resource.created_at.strftime("%Y-%m-%d")}/#{resource.id}/logo"}

  after_create :refresh_category

  before_create :get_short_url

  def get_short_url
    token = Weibotoken.get('sina', 'babycalendar')
    user_weibo = UserWeibo.find(:first, :order=>"id desc")
    text = `curl 'https://api.weibo.com/2/short_url/shorten.json?url_long=#{URI.encode(self.page_url)}&source=#{token.token}&access_token=#{user_weibo.access_token}'`
    res_json = JSON.parse(text)
    if res_json['urls'] && res_json['urls'].size > 0
      self.short_url = res_json['urls'][0]["url_short"]
    end
  end

  def refresh_category
    self.video_category.refresh_video_count()
  end

  def self.json_attrs
    [:id, :name, :url, :page_url, :visit_count, :short_url]
  end
  
  def self.json_methods
    %w{logo_url logo_thumb160 logo_thumb320}
  end
  
  def logo_url
    self.logo.url if self.logo
  end
  
  def logo_thumb160
    self.logo.thumb160.url if self.logo
  end

  def logo_thumb320
    self.logo.thumb160.url if self.logo
  end
  
  def as_json(options = {})
    options[:only] ||= VideoResource.json_attrs
    options[:methods] ||= VideoResource.json_methods
    super options
  end
end
