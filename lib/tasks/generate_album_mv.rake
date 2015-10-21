require 'json'
require 'RMagick'

namespace :mamashai do
	desc "生成照片书mv"
	task :generate_album_mv  => [:environment] do
		book = AlbumBook.find(157)
		dir = File.join(book.logo1.dir, "..")
		json = JSON.parse(book.content)
		json['pages'].each_with_index{|page, index|
			img = Magick::Image.new(600, 600)  		#生成白布底图
			template_path = page["template"]["logo_url"].gsub("http://www.mamashai.com", RAILS_ROOT + "/public")
			
			
			if %w(biaoqing shijian bbyulu caiyi).include?(page['from']) || page['from'].to_s.index("lama")
				#添加背景
				src = Magick::Image::read(template_path).first 
				img = img.composite(src, 0, 0, Magick::OverCompositeOp)

				path = File.join(RAILS_ROOT, "public", page['picture'])
				img2  = Magick::Image.read(path).first
				width_origin = img2.columns.to_i
				height_origin = img2.rows.to_i

				ratio_height = 600.0/height_origin
				ratio_width  = 600.0/width_origin
				
				ratio = ratio_width > ratio_height ? ratio_height : ratio_width
				img2.scale!(ratio)
				left = (600-width_origin*ratio)/2
				img = img.composite(img2, left, 0, Magick::OverCompositeOp)
				#添加图片
			else 
				#添加背景
				template_page = AlbumTemplatePage.find_by_id(page["template"]["id"])
				template_json = JSON.parse(page['template']['json'])
				src = Magick::Image::read(File.join(RAILS_ROOT, 'public', page['template']['logo_url'])).first 
				img = img.composite(src, 0, 0, Magick::OverCompositeOp)
				
				#添加图片
				if page['picture']
					path = File.join(RAILS_ROOT, "public", page['picture'])
					img2  = Magick::Image.read(path).first
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
					img = img.composite(img2, img_left, img_top, Magick::OverCompositeOp)
				end

				#左上角的日期
				if page['created_at'].to_s.size > 0
					if template_json['fullscreen']		#全屏模式，要加半透明图片
						src = Magick::Image::read(File.join(RAILS_ROOT, "/public/images/album_book/fullscreen_date.png")).first 
						img.composite(src, 0, 28, Magick::OverCompositeOp)
					end

					birthday = book.kid.birthday
					stamp = Time.parse(page['created_at'])
					text = stamp.strftime('%Y.%m.%d') + ' ' + book.kid.name + detail_age_for_birthday(birthday, stamp)
					
					gc = Magick::Draw.new
					gc.annotate(img, 200, 28, 12, 36, text) do
			            self.pointsize  = 12
			            self.font       = "#{RAILS_ROOT}/public/font/yahei.TTF"
			            self.fill       = template_json['date_color'] ? "white" : template_json['date_color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff")
			            self.gravity    = Magick::NorthWestGravity
			        end
				end

				#添加用户文字
				#if template_json['fullscreen']                #全屏模式，要加半透明背景图
				#	left = template_json['text']['left'].to_i*PAGE_WIDTH/600.mm
				#	top = PAGE_WIDTH-(template_json['text']['top'].to_i*PAGE_WIDTH/600.mm)
				#	width = template_json['text']['width'].to_i * PAGE_WIDTH/600.mm if template_json['text']['width']
				#	width = PAGE_WIDTH - (template_json['text']['right'].to_i.mm + template_json['text']['left'].to_i.mm)*PAGE_WIDTH/600.mm if template_json['text']['right']
				#	height = template_json['text']['height'].to_i.mm * PAGE_WIDTH/600.mm
				#	pdf.fill_color "FFFFFF"

				#	pdf.transparent(0.4) do
				#		pdf.fill_rounded_rectangle [left - 3.mm, from_bottom + top + 3.mm], width+6.mm, height+6.mm, 3.mm
				#	end
				#end

				#文字，无法折行，暂时屏蔽
				left = template_json['text']['left'].to_i
				top =  template_json['text']['top'].to_i
				width = template_json['text']['width'].to_i if template_json['text']['width']
				width = 600 - (template_json['text']['right'].to_i + template_json['text']['left'].to_i) if template_json['text']['right']
				height = template_json['text']['height'].to_i

				#img2 = Magick::Image.read("caption:" + page['text']) do
				#	self.size = "#{width}x#{height}"
				#	p "#{width}x#{height}"
				#	self.pointsize = 17
				#	self.font = "#{RAILS_ROOT}/public/font/yahei.TTF" 
				#	self.background_color = 'none'
				#end 
				#img = img.composite(img2.first, left, top, Magick::OverCompositeOp)
				
				
				word_wrap(page["text"], width/18).split("\n").each_with_index do |row, i|
					gc = Magick::Draw.new
					p "#{width}~~~~~~~~~~~~~~~~~~~~~~#{row}"
					gc.annotate(img, width, height, left, top+i*25, row) do
				        self.pointsize  = 17
				        self.font       = "#{RAILS_ROOT}/public/font/yahei.TTF"
				        self.fill       = template_json['text']['color'].gsub("red", "#ff0000").gsub("white", "#ffffff").gsub("black", "#000000").gsub(/#fff$/, "#ffffff").gsub(/#000$/, "#000000")
				        self.gravity    = Magick::NorthWestGravity
				    end
				end
			end

			p File.join(book.logo1.dir, "..", "#{index}.jpg")
			img.write File.join(book.logo1.dir, "..", "#{index}.jpg")
			
			p page
			p index
		}
	end

	def word_wrap(text, columns = 80)
      p text
	  cursor = columns
	  while text.mb_chars.size > cursor
	  	text.mb_chars.insert(cursor, "\n")
	  	cursor += columns + 1
	  end
	  p text
	  text
	end
end
