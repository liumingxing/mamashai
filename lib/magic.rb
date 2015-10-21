require 'rubygems'
require 'RMagick'  
include Magick

class String   
   def to_gbk
     begin
        Iconv.iconv("GBK", "UTF-8", self)[0]
     rescue 
        self
     end
   end  
   
   def to_utf8
    begin
        Iconv.iconv("UTF-8", "GBK", self)[0]
     rescue 
        self
     end
   end 
   
   def utf8?     
          unpack('U*') rescue return false     
          true     
   end  
end

ROOT = '..'

def make_lama(time, child_str1, child_str2)
  canvas = Image.new(355, 489, Magick::HatchFill.new('white','white'))  
  gc = Magick::Draw.new
  #gc.stroke('black')
  #gc.fill_opacity(0)
  #gc.stroke_opacity(0.75)
  #gc.stroke_width(6)
  #gc.stroke_linecap('round')
  #gc.stroke_linejoin('round')
  #gc.ellipse(canvas.rows/2,canvas.columns/2, 80, 80, 0, 315)
  #gc.polyline(180,70, 173,78, 190,78, 191,62)
  #gc.stroke_width(1)
  #
  #gc.pointsize(24)
  
  #画边框
  gc.stroke('black')
  gc.stroke_width(1)
  gc.fill('white')
  gc.rectangle(5, 6, 350, 483)
  
  #画日期
  gc.stroke('#990000')
  gc.font("simsun.ttc")
  gc.fill('#990000')
  gc.pointsize(13)
  gc.text(270, 24, time.strftime("%Y年%m月"))
  gc.pointsize(22)
  gc.text(275, 46, time.strftime("%d日"))
  gc.pointsize(13)
  gc.text(275, 61, child_str1)
  gc.pointsize(13)
  gc.text(270, 78, child_str2)
  
  #画黄框
  gc.stroke('#FCD629')
  gc.fill('#FCD629')
  gc.rectangle(10, 85, 345, 476)
  
  gc.draw(canvas)
  
  
  src = Magick::Image.read(ROOT + "/public/images/lama/1/1.jpg")[0]
  canvas = canvas.composite(src, Magick::NorthWestGravity, 10, 10,Magick::OverCompositeOp)
  
  canvas.display
  #canvas.write('love.jpg')  
end

make_lama(Time.new, '悦儿3岁', '2个月25天')




