require 'RMagick'

class AlbumBook < ActiveRecord::Base
  belongs_to :user
  belongs_to :kid, :class_name=>"UserKid"
  belongs_to :album_template, :foreign_key=>"template_id"
  
  upload_column :logo, :versions => {:thumb150 => "150x150", :thumb300 => "300x300", :thumb500 => "500x500"}, :store_dir=>proc{|post, file| "album_book/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo" }
  upload_column :logo1, :versions => {:thumb150 => "c150x150", :thumb300 => "c300x300", :thumb500 => "c500x500"}, :store_dir=>proc{|post, file| "album_book/#{post.created_at.strftime("%Y-%m-%d")}/#{post.id}/logo1" }
  
  named_scope :not_hide, :conditions=>"is_hide = 0"

  before_save :check_kid_id

  before_save :make_logo1

  def upload_to_aliyun
    return if !self.logo1
    return if !File.exist?(self.logo1.path)
    
    begin
      $connection.put("upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo1/#{self.logo1.filename}", File.open(self.logo1.path), {:content_type => self.logo1.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo1/#{self.logo1.thumb150.filename}", File.open(self.logo1.thumb150.path), {:content_type => self.logo1.thumb150.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo1/#{self.logo1.thumb300.filename}", File.open(self.logo1.thumb300.path), {:content_type => self.logo1.thumb300.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/logo1/#{self.logo1.thumb500.filename}", File.open(self.logo1.thumb500.path), {:content_type => self.logo1.thumb500.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    
      0.upto(100) do |i|
        path = "#{::Rails.root.to_s}/public/upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/#{i}.jpg"
        break if !File.exist?(path)
        $connection.put("upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}/#{i}.jpg", File.open(path), {:content_type => "image/jpeg"})
      end
    rescue Exception => err
    end
  end


  def make_logo1
      json = JSON.parse(self.content)
      for page in json['pages']
        if page['picture'] && page['picture'].size > 0 && page['picture'].include?('upload')
          path = ::Rails.root.to_s + "/public" + page['picture']
          if File.exist?(path)
            self.logo1 = File.open(path, 'r')
          else
            begin
              self.logo1 = open("http://mamashai-videos.oss-cn-qingdao-internal.aliyuncs.com" + page['picture'])
            rescue
            end
          end
          return
        end
      end
    
  end

  def check_kid_id
    if !self.kid_id && self.user.user_kids.size > 0
      self.kid_id = self.user.user_kids.first.id
    end
  end

  def self.json_attrs
    [:id, :name, :template_id, :created_at, :updated_at, :like_count, :comment_count, :kid_id, :recommand]
  end

  def self.full_json_attrs
    [:id, :name, :content, :template_id, :created_at, :updated_at, :like_count, :comment_count, :kid_id]
  end

  #def kid
  #  if self.kid_id
  #    UserKid.find_by_id(self.kid_id)
  #  else
  #    self.user.user_kids.first
  #  end
  #end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{logo_url logo_url_thumb150 logo_url_thumb300 logo_url_500}
  end
  
  # 图片地址
  def logo_url
    logo1.try(:url)
  end

  # 缩略图地址
  def logo_url_thumb150
    logo1.try(:thumb150).try(:url)
  end

  def logo_url_thumb300
    logo1.try(:thumb300).try(:url)
  end
  
  def logo_url_thumb500
    logo1.try(:thumb500).try(:url)
  end

  def as_json(options = {})
    options[:only] ||= AlbumBook.json_attrs
    options[:methods] ||= AlbumBook.json_methods
    options[:include] ||= {:user=>{:only=>User.json_attrs, :methods=>User.json_methods, :include=>{:user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}}, :kid=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}
    super options
  end

  def word_wrap(text, columns = 80)
    cursor = columns
    while text.mb_chars.size > cursor
      text.mb_chars.insert(cursor, "\n")
      cursor += columns + 1
    end
    text
  end

  def make_mv
    return if !self.logo1

    `mkdir #{::Rails.root.to_s}/public/upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}`
    `mkdir #{::Rails.root.to_s}/public/upload/album_book/#{self.created_at.strftime("%Y-%m-%d")}/#{self.id}`
    json = JSON.parse(self.content)
    json['pages'].each_with_index{|page, index|
      begin
        img = Magick::Image.new(600, 600)     #生成白布底图
        template_path = page["template"]["logo_url"].gsub("http://www.mamashai.com", ::Rails.root.to_s + "/public")
        if template_path.index('/upload') == 0
          template_path = ::Rails.root.to_s + "/public" + template_path
        end

        if %w(biaoqing shijian bbyulu caiyi).include?(page['from']) || page['from'].to_s.index("lama")
          #添加背景
          src = Magick::Image::read(template_path).first 
          img.composite!(src, 0, 0, Magick::OverCompositeOp)
          src.destroy!

          path = File.join(::Rails.root.to_s, "public", page['picture'])
          img2  = Magick::Image.read(path).first
          width_origin = img2.columns.to_i
          height_origin = img2.rows.to_i

          ratio_height = 600.0/height_origin
          ratio_width  = 600.0/width_origin
          
          ratio = ratio_width > ratio_height ? ratio_height : ratio_width
          img2.scale!(ratio)
          left = (600-width_origin*ratio)/2
          img.composite!(img2, left, 0, Magick::OverCompositeOp)
          img2.destroy!

          #添加图片
        else 
          #添加背景
          template_page = AlbumTemplatePage.find_by_id(page["template"]["id"])
          template_json = JSON.parse(page['template']['json'])
          src = Magick::Image::read(File.join(::Rails.root.to_s, 'public', page['template']['logo_url'])).first 
          
          img.composite!(src, 0, 0, Magick::OverCompositeOp)
          src.destroy!

          #添加图片
          if page['picture']
            if page["picture"].to_s.index('/upload/album_page') == 0 
              img2 = Magick::ImageList.new("http://mamashai-videos.oss-cn-qingdao-internal.aliyuncs.com" + page['picture']).first
              p "http://mamashai-videos.oss-cn-qingdao-internal.aliyuncs.com" + page['picture']
            else
              path = File.join(::Rails.root.to_s, "public", page['picture'])
              img2  = Magick::Image.read(path).first
            end

            width_origin = img2.columns.to_i
            height_origin = img2.rows.to_i
            width_rect = template_json['picture']['width'].to_i
            height_rect = template_json['picture']['height'].to_i

            if height_rect/width_rect > height_origin/width_origin
              width = width_rect
              height = width_rect * height_origin/width_origin
            else
              height = height_rect
              width = height_rect * width_origin/height_origin
            end

            top = (height_rect - height)/2
            left = (width_rect - width)/2

            #先缩放,暂定按左上角为中心滚动
            if page['scroll'] && page['scroll']['scale']
              width = width * page['scroll']['scale'].to_f
              height = height * page['scroll']['scale'].to_f
              top = top * page['scroll']['scale'].to_f
              left = left * page['scroll']['scale'].to_f
            end

            #再滚动
            if page['scroll'] && page['scroll']['x']
              left = left - page['scroll']['x'].to_i*2
              top = top - page['scroll']['y'].to_i*2
            end

            #没有滚动
            ratio = width_origin*1.0/width
            img2.crop!(0-left*ratio, 0-top*ratio, width_rect*ratio, height_rect*ratio)
            ratio_width = width_rect*1.0/(width_rect*ratio)
            ratio_height = height_rect*1.0/(height_rect*ratio)
            img2.scale!(ratio_width > ratio_height ? ratio_height : ratio_width)
            
            picture_json = template_json['picture']
            img_left = picture_json['left']
            img_top  = picture_json['top']
            img_width = picture_json['width']
            img_height = picture_json['height']

            img_left += (img_width - img2.columns.to_i)/2
            img_top += (img_height - img2.rows.to_i)/2
            img.composite!(img2, img_left, img_top, Magick::OverCompositeOp)
            img2.destroy!
          end

          #左上角的日期
          if page['created_at'].to_s.size > 0
            if template_json['fullscreen']    #全屏模式，要加半透明图片
              src = Magick::Image::read(File.join(::Rails.root.to_s, "/public/images/album_book/fullscreen_date.png")).first 
              img.composite!(src, 0, 28, Magick::OverCompositeOp)
              src.destroy!
            end

            stamp = Time.parse(page['created_at'])
            text = stamp.strftime('%Y.%m.%d')
            if self.kid && self.kid.birthday
              birthday = self.kid.birthday
              text = stamp.strftime('%Y.%m.%d') + ' ' + self.kid.name + detail_age_for_birthday(birthday, stamp)
            end
            
            gc = Magick::Draw.new
            gc.annotate(img, 200, 28, 12, 36, text) do
                    self.pointsize  = 13
                    self.font       = "#{::Rails.root.to_s}/public/font/yahei.TTF"
                    self.fill       = !template_json['date_color'] ? "white" : template_json['date_color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff")
                    self.gravity    = Magick::NorthWestGravity
            end
          end

          #文字，无法折行，暂时屏蔽
          left = template_json['text']['left'].to_i
          top =  template_json['text']['top'].to_i
          width = template_json['text']['width'].to_i if template_json['text']['width']
          width = 600 - (template_json['text']['right'].to_i + template_json['text']['left'].to_i) if template_json['text']['right']
          height = template_json['text']['height'].to_i
          
          if template_json['fullscreen'] && page["text"].to_s.size > 0
            gc = Magick::Draw.new
            gc.fill("#ccc")
            gc.fill_opacity("40%")
            gc.opacity("40%")
            gc.stroke_opacity('40%')
            gc.stroke_width(0)
            gc.roundrectangle(left-8, top-8, left + width+16, top+height+16, 8, 8)
            gc.draw(img)
          end

          word_wrap(page["text"]||" ", width/18).split("\n").each_with_index do |row, i|
            gc = Magick::Draw.new
            gc.annotate(img, width, height, left, top+i*25, row) do
                  self.pointsize  = 17
                  self.font       = "#{::Rails.root.to_s}/public/font/yahei.TTF"
                  self.fill       = template_json['text']['color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff").gsub(/#000$/, "#000000")
                  self.gravity    = Magick::NorthWestGravity
              end if row.to_s.size > 0 && row != '文字' 
          end if  page["text"].to_s.size > 0
        end

        img.write File.join(self.logo1.dir, "..", "#{index}.jpg")
        img.destroy!

      rescue => err
        p err
        p err.backtrace
      end
    }

    upload_to_aliyun
  end

  def detail_age_for_birthday(birthday, today=Date.today)
    str = ''
    motn_days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if today.year % 4 == 0
      motn_days[1] = 29;
    end
    if birthday
      _birthday = birthday
      if today < birthday 
        pregnant_day = birthday - 280 
        birthday = pregnant_day
      end
      months = today.month - birthday.month
      years = today.year - birthday.year
      days = today.day - birthday.day 
      if today >= birthday 
        if months < 0
          years -=1
          months = 12 + months
        end
        if days < 0
          months -=1
          days = motn_days[birthday.month-1] + days
        end
        if months < 0
          years -=1
          months = 12 + months
        end
        if pregnant_day
          today_date = Date.new(today.year, today.month, today.mday)
          diff_days = 280 - (_birthday - today_date).to_i
          str = "孕"
          str += (diff_days/7).to_s + "周" if diff_days/7 > 0
          str += (diff_days%7).to_s + "天" if diff_days%7 > 0 
          str = "出生啦" if diff_days == 280
          puts str
          #str = "#{APP_CONFIG['have_baby']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        else
          if years == 0 && months == 0 && days == 0
            return "出生啦"
          end
          str = ""
          str += "#{years}#{APP_CONFIG['age']}" if years > 0
          str += "#{months}个#{APP_CONFIG['time_label_m']}" if months > 0
          str += "#{days}#{APP_CONFIG['day']}" if days > 0
          #str = "#{years}#{APP_CONFIG['age']}#{months}个#{APP_CONFIG['time_label_m']}#{days}#{APP_CONFIG['day']}"
        end
      end
    end
    str
  end 
end
