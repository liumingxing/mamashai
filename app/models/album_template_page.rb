class AlbumTemplatePage < ActiveRecord::Base
  belongs_to :album_template

  upload_column :logo_phone, :versions => {:thumb400 => "400x400"}, :store_dir=>proc{|picture, file| "album_template_pages/#{picture.created_at.strftime("%Y-%m-%d")}/#{picture.id}/logo_phone"}
  upload_column :logo_print, :versions => {:thumb400 => "400x400"}, :store_dir=>proc{|picture, file| "album_template_pages/#{picture.created_at.strftime("%Y-%m-%d")}/#{picture.id}/logo_print"}

  def self.json_attrs
    [:id, :album_template_id, :logo_url, :json]
  end
  
  # 图片地址
  def logo_url
    logo_phone.try(:url)
  end
  
  # 缩略图地址
  def logo_url_thumb400
    logo_phone.try(:thumb400).try(:url)
  end
  
  def self.json_methods
    %w{logo_url logo_url_thumb400 pic_width pic_height}
  end
  
  #插入图片的宽度
  def pic_width
    if self.json && self.json.to_s.size > 0
      @json = @json || JSON.parse(self.json)
      if @json['picture']
        @json['picture']['width']
      else
        nil
      end
    else
      nil
    end    
  end

  #插入图片的高度
  def pic_height
    if self.json && self.json.to_s.size > 0
      @json = @json || JSON.parse(self.json)
      if @json['picture']
        @json['picture']['height']
      else
        nil
      end
    else
      nil
    end
  end

  def as_json(options = {})
    options[:only] ||= AlbumTemplatePage.json_attrs
    options[:methods] ||= AlbumTemplatePage.json_methods
    super options
  end
end
