require 'fileutils'
require "prawn"
require "prawn/measurement_extensions"

module MamashaiTools
  class PdfUtil
    def initialize
    end
    
    def self.book_page_layout(layout)
      text_params = {:size => 11, :spacing => 6, :wrap => :character,:overflow=>:expand}
      if layout == 1
        return {:image=>{:at=>[84,530],:fit=>[245,168],:width=>245},
          :text1=>{:at=>[48,278],:width=>305,:height=>200}.merge!(text_params)} 
      end
      if layout == 2
        return {:image=>{:at=>[75,245],:fit=>[245,168],:width=>245},
          :text1=>{:at=>[45,530],:width=>305,:height=>200}.merge!(text_params)} 
      end
      if layout == 3
        return {:image=>{:at=>[84,530],:fit=>[245,168],:width=>245},
          :text1=>{:at=>[54,292],:width=>305,:height=>110}.merge!(text_params),
          :text2=>{:at=>[138,153],:width=>228,:height=>96}.merge!(text_params)} 
      end
      if layout == 4
        return {:image=>{:at=>[88,445],:fit=>[230,165],:width=>230},
          :text1=>{:at=>[45,550],:width=>316,:height=>85}.merge!(text_params),
          :text2=>{:at=>[155,236],:width=>218,:height=>180}.merge!(text_params)} 
      end
      if layout == 5
        return {:image=>{:at=>[67,357],:fit=>[165,205],:width=>165},
          :text1=>{:at=>[57,540],:width=>312,:height=>110}.merge!(text_params),
          :text2=>{:at=>[255,380],:width=>120,:height=>180}.merge!(text_params),
          :text3=>{:at=>[63,87],:width=>305,:height=>65}.merge!(text_params)} 
      end
      if layout == 6
        return {:image=>{:at=>[210,265],:fit=>[160,230],:width=>160},
          :text1=>{:at=>[200,535],:width=>180,:height=>190}.merge!(text_params),
          :text2=>{:at=>[45,360],:width=>120,:height=>230}.merge!(text_params)} 
      end
      if layout == 7
        return {:image=>{:at=>[213,535],:fit=>[160,213],:width=>160},
          :text1=>{:at=>[30,550],:width=>150,:height=>200}.merge!(text_params),
          :text2=>{:at=>[100,220],:width=>270,:height=>140}.merge!(text_params)} 
      end
      if layout == 8
        return {:image=>{:at=>[60,250],:fit=>[145,220],:width=>145},
          :text1=>{:at=>[60,530],:width=>300,:height=>102}.merge!(text_params),
          :text2=>{:at=>[120,377],:width=>250,:height=>90}.merge!(text_params),
          :text3=>{:at=>[235,270],:width=>140,:height=>170}.merge!(text_params)} 
      end
      if layout == 9
        return {:image=>{:at=>[52,523],:fit=>[210,150],:width=>210},
          :text1=>{:at=>[298,505],:width=>90,:height=>140}.merge!(text_params),
          :text2=>{:at=>[34,330],:width=>150,:height=>290}.merge!(text_params),
          :text3=>{:at=>[227,330],:width=>150,:height=>290}.merge!(text_params)} 
      end
      if layout == 10
        return {:image=>{:at=>[70,205],:fit=>[245,170],:width=>245},
          :text1=>{:at=>[60,548],:width=>230,:height=>90}.merge!(text_params),
          :text2=>{:at=>[65,420],:width=>310,:height=>80}.merge!(text_params),
          :text3=>{:at=>[180,340],:width=>200,:height=>100}.merge!(text_params)} 
      end
    end
    
    def self.book_cover_layout(layout)
      return {:image=>{:at=>[50,410],:fit=>[75,75]},:title=>{:at=>[46,310]},:author=>{:at=>[46,295]}} if layout == 1
      return {:image=>{:at=>[230,480],:fit=>[75,75]},:title=>{:at=>[226,380]},:author=>{:at=>[226,365]}} if layout == 2
      return {:image=>{:at=>[50,410],:fit=>[75,75]},:title=>{:at=>[46,310]},:author=>{:at=>[46,295]}} if layout == 3
      return {:image=>{:at=>[50,410],:fit=>[75,75]},:title=>{:at=>[46,310]},:author=>{:at=>[46,295]}} if layout == 4
    end
    
    def self.book_cover_font_color(skin)
      {1=>'000000',2=>'FFBA00'}[skin]
    end
    
    def self.book_back_font_color(skin)
      {1=>'000000',2=>'FFBA00'}[skin]
    end
    
    def self.book_page_num_font_color(skin)
      {1=>'000000',2=>'FFFFFF'}[skin]
    end
    
    def self.pdf_text_box(pdf,text,layout) 
      if text
        text = MamashaiTools::TextUtil.gsub_pdf_words(text)
        total_lines = 0
        strs = text.split("\n")
        strs.each do |str| 
          native_text = pdf.naive_wrap(str, layout[:width], pdf.font_size,:mode=>:character)
          lines = native_text.lines.to_a.length  
          total_lines += lines
          if((total_lines * (layout[:spacing] + layout[:size])) > layout[:height])
            pdf.text_box(MamashaiTools::TextUtil.truncate(str,(layout[:width]/pdf.font_size+1) * (layout[:height]/(layout[:spacing] + layout[:size])-(total_lines-lines)) ),layout) 
             pdf.stroke_line [pdf.bounds.left,  pdf.bounds.top],
                    [pdf.bounds.right, pdf.bounds.top]
            break
          else
            pdf.text_box(str,layout) 
          end
          add_height = (layout[:spacing] + layout[:size]) * lines 
          add_height += layout[:spacing] if lines > 1 
          layout[:at][1] -= add_height
        end
      end
    end
    
    def self.generate_user_book_pdf(user_book) 
      file_name = user_book.created_at.strftime("%Y%m%d%M%S")+".pdf"
      UserBook.update_all(["file=?",file_name],["id=?",user_book.id])
      user_book = UserBook.find(user_book.id)
      path = "#{::Rails.root.to_s}/public#{user_book.file.url}"
      FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
      Prawn::Document.generate(path, :page_size => "A5",:left_margin => 0.mm,:right_margin => 0.mm,:top_margin => 0.mm,:bottom_margin => 0.mm) do  |pdf|
        skin_dir = "public/images/book/skin#{user_book.skin}/print"
        pdf.font "#{Prawn::BASEDIR}/data/fonts/simsun.ttf"
        
        self.generate_book_cover(pdf,skin_dir,user_book) 
        user_book.user_book_pages.each do |book_page|
          self.generate_book_page(pdf,skin_dir,user_book,book_page)
        end 
        self.generate_book_cover_back(pdf,skin_dir,user_book) 
      end
    end
    
    def self.generate_book_page(pdf,skin_dir,user_book,book_page) 
      pdf.image "#{::Rails.root.to_s}/#{skin_dir}/layout#{book_page.layout}.jpg", :position => :center, :vposition => :bottom, :width => 419 
      post = book_page.post
      picture_url = ( book_page.logo.blank? ? post.logo.url : book_page.logo.url)
      layout = self.book_page_layout(book_page.layout)
      self.generate_book_page_num(pdf,skin_dir,user_book,book_page)
      pdf.fill_color "000000"
      pdf.bounding_box(layout[:image][:at],:width=>layout[:image][:width]) do
        pdf.image "#{::Rails.root.to_s}/public#{picture_url}", :fit => layout[:image][:fit],:position => :center, :vposition => :top
      end  
      
      self.pdf_text_box(pdf,book_page.content1,layout[:text1]) if layout[:text1]
      self.pdf_text_box(pdf,book_page.content2,layout[:text2]) if layout[:text2]
      self.pdf_text_box(pdf,book_page.content3,layout[:text3]) if layout[:text3]
      
    end
    
    def self.generate_book_page_num(pdf,skin_dir,user_book,book_page)
      pdf.fill_color self.book_page_num_font_color(user_book.skin)
      page_offset = ( book_page.page_num < 10 ? 3 : 0)
      if book_page.page_num % 2 == 0
        pdf.image "#{::Rails.root.to_s}/#{skin_dir}/page.jpg", :at => [27,586], :width => 25
        pdf.font_size(9) { pdf.text book_page.page_num, :at => [33+page_offset,570] }
      else
        pdf.image "#{::Rails.root.to_s}/#{skin_dir}/page.jpg", :at => [346,586], :width => 25
        pdf.font_size(9) { pdf.text book_page.page_num, :at => [352+page_offset,570] }
      end 
    end
    
    def self.generate_book_cover(pdf,skin_dir,user_book)
      pdf.fill_color self.book_cover_font_color(user_book.skin)
      pdf.image "#{::Rails.root.to_s}/#{skin_dir}/cover.jpg", :position => :center, :vposition => :bottom, :width => 419,:height=>595
      layout = self.book_cover_layout(user_book.layout)
      if user_book.logo
        pdf.image "#{::Rails.root.to_s}/public#{user_book.logo.url}", :at =>layout[:image][:at] , :fit => layout[:image][:fit]
      end
      pdf.font_size(17) { pdf.text MamashaiTools::TextUtil.gsub_pdf_words(user_book.title), :at => layout[:title][:at],:font_weight=>'bold' }
      pdf.font_size(8) { pdf.text "#{APP_CONFIG['user_book_author1']} #{user_book.author1} #{APP_CONFIG['user_book_author2']} #{user_book.author2}", :at => layout[:author][:at] }
    end
    
    def self.generate_book_cover_back(pdf,skin_dir,user_book)
      pdf.fill_color self.book_back_font_color(user_book.skin)
      user = user_book.user
      user_url =  "#{WEB_ROOT}/space/user/#{user.id}" 
      user_url =  "#{WEB_ROOT}/u/#{user.domain}" if user.domain 
      pdf.image "#{::Rails.root.to_s}/#{skin_dir}/back.jpg", :position => :center, :vposition => :bottom, :width => 419
      pdf.font_size(8) { pdf.text "#{user_book.user.name}#{APP_CONFIG['user_book_back_title']}", :at => [160,485] }
      pdf.font_size(8) { pdf.text user_url, :at => [130,475] }
      pdf.font_size(7) { pdf.text user_book.author1, :at => [291,87] }
      pdf.font_size(7) { pdf.text user_book.author2, :at => [291,75] }
      user_order = user_book.user_order
      if user_order
        pdf.fill_color '000000'
        pdf.font_size(5) { pdf.text "0#{user_order.order_no}", :at => [61,57] }
      end
    end
    
    
  end
end
