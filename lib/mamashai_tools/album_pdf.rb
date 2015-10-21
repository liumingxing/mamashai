require 'prawn'
require "prawn/measurement_extensions"
require 'json'
require 'RMagick'

module MamashaiTools
  PAGE_WIDTH = 145.mm
  PAPER_WIDTH = 210.mm
  PAPER_HEIGHT = 297.mm
  def self.generate_album_pdf(id)
    book = AlbumBook.find(id)

    path = "public/upload/album_orders/#{book.created_at.to_date.to_s(:db)}"
    Dir.mkdir(path) if !File.exist?(path)

    Prawn::Document.generate("#{path}/#{book.id}.pdf", :page_size=>"A4", :left_margin=>(PAPER_WIDTH-PAGE_WIDTH)/2, :top_margin=>0.mm, :bottom_margin=>0.mm) do |pdf|
      pdf.font "#{::Rails.root.to_s}/public/font/yahei.TTF"
      pdf.default_leading 5

      pages = JSON.parse(book.content)["pages"]

      #加入封面2
      fm_page2 = Hash.new
      fm_page2['status'] = 'fm2'
      pages.unshift(fm_page2)

      #加入封面1
      fm = AlbumTemplatePage.find(:first, :conditions=>"album_template_id = #{book.template_id} and status='fm'")
      fm_page = Hash.new
      fm_page['status'] = 'fm1'
      fm_page['text'] = book.name
      fm_page['template'] = JSON.parse(fm.to_json)
      pages.unshift(fm_page)

      #加入封面3
      fm_page3 = Hash.new
      fm_page3['status'] = 'fm3'
      pages.push(fm_page3)

      #加入封面4
      fm_page4 = Hash.new
      fm_page4['status'] = 'fm4'
      pages.push(fm_page4)

      pages.each_slice(4).with_index{|page_group, page_index_1|
        pdf.start_new_page(:page_size=>"A4", :left_margin=>(PAPER_WIDTH-PAGE_WIDTH)/2, :top_margin=>0.mm, :bottom_margin=>0.mm) if page_index_1 > 0

        page_group[1], page_group[2] = page_group[2], page_group[1]
        page_group.each_with_index{|page, page_index_2|
          pdf.start_new_page(:page_size=>"A4", :left_margin=>(PAPER_WIDTH-PAGE_WIDTH)/2, :top_margin=>0.mm, :bottom_margin=>0.mm) if page_index_2 == 2
          #开始打印页面
          from_bottom = page_index_2 % 2 == 0 ? PAPER_HEIGHT/2 : 2.mm
          if page['status'] == 'fm2'
            print_fm2(book, pdf, from_bottom)
          elsif page['status'] == 'fm3'
            print_fm3(book, pdf, from_bottom)
          elsif page['status'] == 'fm4'
            print_fm4(book, pdf, from_bottom)
          else
            print_a_page(book, pdf, page, from_bottom, page_index_1, page_index_2)
          end

          blood(pdf) if page_index_2 == 1

        }
      }
    end
  end

  def blood(pdf)
        #打出血线
        pdf.stroke do
          right = PAGE_WIDTH
          blank = (PAPER_WIDTH - PAGE_WIDTH)/2
          pdf.horizontal_line -blank.mm, 5.mm, :at=>4.mm
          pdf.horizontal_line right-5.mm, right+blank.mm, :at=>4.mm
          
          pdf.horizontal_line -blank.mm, 5.mm, :at=>PAGE_WIDTH
          pdf.horizontal_line right-5.mm, right+blank.mm, :at=>PAGE_WIDTH

          pdf.horizontal_line -blank.mm, 5.mm, :at=>PAGE_WIDTH + 6.mm
          pdf.horizontal_line right-5.mm, right+blank.mm, :at=>PAGE_WIDTH + 6.mm
          
          pdf.horizontal_line -blank.mm, 5.mm, :at=>PAGE_WIDTH*2 + 2.mm
          pdf.horizontal_line right-5.mm, right+blank.mm, :at=>PAGE_WIDTH*2 + 2.mm

          pdf.vertical_line 0.mm, 6.mm, :at=>2.mm
          pdf.vertical_line PAGE_WIDTH*2-3.mm, PAGE_WIDTH*2+8.mm, :at=>2.mm
          pdf.vertical_line 0.mm, 6.mm, :at=>PAGE_WIDTH-2.mm
          pdf.vertical_line PAGE_WIDTH*2-3.mm, PAGE_WIDTH*2+8.mm, :at=>PAGE_WIDTH-2.mm

          pdf.vertical_line PAGE_WIDTH-2.mm, PAGE_WIDTH+8.mm, :at=>2.mm
          pdf.vertical_line PAGE_WIDTH-2.mm, PAGE_WIDTH+8.mm, :at=>PAGE_WIDTH-2.mm
        end
  end

  def self.print_a_page(book, pdf, page, from_bottom, index_1, index_2)
    if %w(biaoqing shijian bbyulu caiyi).include?(page['from']) || page['from'].to_s.index("lama")
      #设置背景图
      path = page["template"]["logo_url"].gsub("http://www.mamashai.com", ::Rails.root.to_s + "/public").gsub(".png", "@2x.jpg")
      pdf.image path, :at=>[0, from_bottom + PAGE_WIDTH], :width=>PAGE_WIDTH, :height=>PAGE_WIDTH if File.exist?(path)

      pdf.bounding_box([0, from_bottom + PAGE_WIDTH-3.mm], :width => PAGE_WIDTH, :height => PAGE_WIDTH-6.mm) do
        path = ::Rails.root.to_s + "/public" + page['picture']
        pdf.image path, :position=>:center, :vposition=>:center, :height=>PAGE_WIDTH - 6.1.mm
      end
      return
    end

    #设置背景图
    template_page = AlbumTemplatePage.find_by_id(page["template"]["id"])
    if template_page
      pdf.image template_page.logo_print.path, :at=>[0, from_bottom + PAGE_WIDTH], :width=>PAGE_WIDTH, :height=>PAGE_WIDTH if File.exist?(template_page.logo_print.path)
    end
    template_json = JSON.parse(page['template']['json'])

    #图片
    if page['picture']
      path = ::Rails.root.to_s + "/public" +page['picture'].gsub("_thumb400.", ".")
      path = ::Rails.root.to_s + "/public" +page['picture'] if !File.exist?(path)
      img  = Magick::Image.read(path).first
      width_origin = img.columns.to_i
      height_origin = img.rows.to_i
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
      img.crop!(0-left*ratio, 0-top*ratio, width_rect*ratio, height_rect*ratio)
      path = "./tmp/#{Time.new.to_i}.jpg"
      img.write(path)
      picture_json = template_json['picture']
      img_left = picture_json['left'].to_i.mm*PAGE_WIDTH/600.mm
      img_top  = PAGE_WIDTH - picture_json['top'].to_i.mm*PAGE_WIDTH/600.mm
      img_width = picture_json['width'].to_i.mm*PAGE_WIDTH/600.mm
      img_height = picture_json['height'].to_i.mm*PAGE_WIDTH/600.mm
      pdf.bounding_box([img_left, from_bottom + img_top], :width => img_width, :height => img_height) do
        pdf.image path, :fit=>[img_width, img_height], :position=>:center, :vposition=>:center
      end
    end

    #左上角的日期
    if page['created_at'].to_s.size > 0
      if template_json['fullscreen']    #全屏模式，要加半透明图片
        pdf.image ::Rails.root.to_s + "/public/images/album_book/fullscreen_date.png", :at=>[0, from_bottom + PAGE_WIDTH-6.95.mm], :width=>49.1.mm, :height=>6.95.mm
      end

      birthday = book.kid.birthday
      stamp = Time.parse(page['created_at'])
      text = stamp.strftime('%Y.%m.%d') + ' ' + book.kid.name + detail_age_for_birthday(birthday, stamp)
      pdf.font_size 2.8.mm
      pdf.fill_color template_json['date_color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff").gsub('#', '') if template_json['date_color']
      pdf.text_box text, :at=>[3.mm, from_bottom + PAGE_WIDTH - 9.6.mm], :width=>48.mm, :height=>7.mm, :align=>:center
    elsif index_1 + index_2 > 0
      if !template_json['fullscreen']
        pdf.font_size 2.8.mm
        pdf.fill_color template_json['date_color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff").gsub('#', '') if template_json['date_color']
        pdf.text_box book.name, :at=>[3.mm, from_bottom + PAGE_WIDTH - 9.6.mm], :width=>48.mm, :height=>7.mm, :align=>:center
      end
    end

    if template_json['fullscreen'] && page['text'].to_s.size > 0 && page['text'] != "文字"        #全屏模式，要加半透明背景图
      left = template_json['text']['left'].to_i.mm*PAGE_WIDTH/600.mm
      top = PAGE_WIDTH-template_json['text']['top'].to_i.mm*PAGE_WIDTH/600.mm
      width = template_json['text']['width'].to_i.mm * PAGE_WIDTH/600.mm if template_json['text']['width']
      width = PAGE_WIDTH - (template_json['text']['right'].to_i.mm + template_json['text']['left'].to_i.mm)*PAGE_WIDTH/600.mm if template_json['text']['right']
      height = template_json['text']['height'].to_i.mm * PAGE_WIDTH/600.mm
      pdf.fill_color "FFFFFF"

      pdf.transparent(0.4) do
        pdf.fill_rounded_rectangle [left - 3.mm, from_bottom + top + 3.mm], width+6.mm, height+6.mm, 3.mm
      end
    end

    #文字
    pdf.font_size 3.6.mm
    left = template_json['text']['left'].to_i.mm*PAGE_WIDTH/600.mm
    top =  PAGE_WIDTH-template_json['text']['top'].to_i.mm*PAGE_WIDTH/600.mm
    width = template_json['text']['width'].to_i.mm * PAGE_WIDTH/600.mm if template_json['text']['width']
    width = PAGE_WIDTH - (template_json['text']['right'].to_i.mm + template_json['text']['left'].to_i.mm)*PAGE_WIDTH/600.mm if template_json['text']['right']
    height = template_json['text']['height'].to_i.mm * PAGE_WIDTH/600.mm
    
    pdf.fill_color template_json['text']['color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff").gsub(/#000$/, "#000000").gsub('#', '')
    if page['status'] == 'fm1'
      pdf.font_size 9.mm
      pdf.text_box page['text'], :at=>[left, from_bottom + top], :width=>width, :align=>:center
    else
      pdf.text_box page['text'], :at=>[left, from_bottom + top], :width=>width if page['text'] != "文字"
    end
  end

  def print_fm2(book, pdf, from_bottom)
    pdf.image "#{::Rails.root.to_s}/public/images/album_book/fuyin/fy-#{book.template_id}.jpg", :at=>[0, from_bottom + PAGE_WIDTH], :width=>PAGE_WIDTH, :height=>PAGE_WIDTH
  end

  def print_fm3(book, pdf, from_bottom)
    pdf.fill_color book.album_template.color
    pdf.fill_rectangle [0, from_bottom + PAGE_WIDTH], PAGE_WIDTH, PAGE_WIDTH

    pdf.image ::Rails.root.to_s + "/public/images/album_book/fm_3_1.png", :at=>[20.mm, from_bottom + 100.mm], :width=>PAGE_WIDTH-40.mm
    pdf.bounding_box([30.mm, from_bottom + 40.mm], :width => PAGE_WIDTH-60.mm, :height => 20.mm) do
      pdf.image ::Rails.root.to_s + "/public/images/album_book/fm_3_2.png", :fit=>[PAGE_WIDTH-60.mm, 20.mm], :positon=>:center, :vposition=>:center
    end
  end

  def print_fm4(book, pdf, from_bottom)
    pdf.fill_color book.album_template.color
    pdf.fill_rectangle [0, from_bottom + PAGE_WIDTH], PAGE_WIDTH, PAGE_WIDTH

    pdf.bounding_box([20.mm, from_bottom + 90.mm], :width => PAGE_WIDTH-40.mm, :height => 80.mm) do
      pdf.font_size 3.2.mm
      pdf.fill_color "#333333"
      pdf.text "书　　名：#{book.name}", :character_spacing => 2
      pdf.move_down 4
      pdf.dash(1, :space => 1, :phase => 0)
      pdf.stroke_horizontal_line 0, PAGE_WIDTH-40.mm
      pdf.move_down 6
      pdf.text "编　　著：#{book.user.name}", :character_spacing => 2
      pdf.move_down 4
      #pdf.move_down 6
      pdf.text "出　　品：妈妈晒", :character_spacing => 2
      pdf.move_down 4
      pdf.text "用户沟通：Tel：010-84873560", :character_spacing => 2
      pdf.move_down 4
      pdf.text "　　　　　QQ：1170979903", :character_spacing => 2
      pdf.dash(1, :space => 1, :phase => 0)
      pdf.stroke_horizontal_line 0, PAGE_WIDTH-40.mm
      pdf.move_down 6
      pdf.text "开　　版：139×139mm", :character_spacing => 2
      pdf.move_down 4
      pdf.text "页　　数：40页", :character_spacing => 2
      pdf.move_down 4
      pdf.text "版　　次：#{book.created_at.year}年#{book.created_at.month}月第1版", :character_spacing => 2
      pdf.move_down 4
      pdf.text "版权所有，侵权必究", :character_spacing => 2
    end

    pdf.image ::Rails.root.to_s + "/public/images/album_book/fm_4_1.png", :at=>[100.mm, from_bottom + 35.mm], :width=>30.mm
  end

  def self.detail_age_for_birthday(birthday, today=Date.today)
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

  #生成一本书的logo
  def self.album_logo(id)
    book = AlbumBook.find(id)
    json = JSON.parse(book.content)
    fm = json['pages'][0]
    fm_json = nil
    fm_json = JSON.parse(fm['template']['json']) if fm['template']

    img = Magick::Image.new(600, 600)
    if %w(biaoqing shijian bbyulu caiyi).include?(first['from']) || first['from'].to_s.index("lama")
      #生成底图
      background = Magick::Image::read(File.join(::Rails.root.to_s, 'public', fm['template']['logo_url'].gsub('http://www.mamashai.com/', ''))).first
      img = img.composite(background, Magick::NorthWestGravity, 0, 0, Magick::OverCompositeOp)

      #生成图片
      if fm.picture
        picture = Magick::Image::read(File.join(::Rails.root.to_s, 'public', fm['picture'])).first
        picture.resize_to_fit!(600, 600)
        img = img.composite(picture, Magick::NorthWestGravity, (600-picture.columns)/2, 0, Magick::OverCompositeOp)
      end
    else
      #生成底图
      background = Magick::Image::read(File.join(::Rails.root.to_s, 'public', fm['template']['logo_url_thumb400'].gsub('_thumb400.', '.'))).first
      img = img.composite(background, Magick::NorthWestGravity, 0, 0, Magick::OverCompositeOp)

      #合成生日
      kid = book.kid
      birthday = kid.birthday
      stamp = Time.parse(fm['created_at'])
      text = stamp.strftime('%Y.%m.%d') + ' ' + kid.name + MamashaiTools.detail_age_for_birthday(birthday, stamp)

      gc.annotate(img, 106, 15, x, 15, text) do
        self.pointsize  = 9
        self.font       = ::Rails.root.to_s + "/public/font/yahei.TTF"
        self.fill       = fm_json['date_color']
      end

      #合成文字
      width = fm_json.width;
      width = (600 - fm_json.left.to_i + fm_json.right.to_i) if !fm_json.width
      height = fm_json.height;
      gc.annotate(img, width, height, fm_json.text.left, fm_json.text.top, fm['text']) do
        self.pointsize  = 10
        self.font       = ::Rails.root.to_s + "/public/font/yahei.TTF"
        self.fill       = fm_json['date_color']
      end

      #合成图片
    end
    path = "#{Time.new.to_i}_#{rand(1000)}.jpg"
    img.write File.join(::Rails.root.to_s, 'public', path)
  end

end