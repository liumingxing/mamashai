require 'nokogiri'
namespace :mamashai do
  # desc "insert_preface_and_end_page"
  # task :insert_preface_and_end_page  => [:environment] do
  #   BabyBook.all.each do |book|
  #     preface_content =  '<?xml version="1.0"?>'
  #     preface_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/preface/html/1.jpg\" wallpaper=\"/images/baby_books/themes/preface/pdf/1.png\" bgcolor=\"white\">"
  #     preface_content << "<box bg_color='white' w='115' x='15' y='20' font_size='' type='text' font_color='#000' font_weight='' layer='1' h='169'><![CDATA[]]></box>"
  #     preface_content << '</page>'

  #     # end_content =  '<?xml version="1.0"?>'
  #     # end_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/end/html/1.jpg\" wallpaper=\"/images/baby_books/themes/end/pdf/1.png\" bgcolor=\"white\">"
  #     # end_content << "<box bg_color='white' w='115' x='15' y='20' font_size='' type='text' font_color='#000' font_weight='' layer='1' h='169'><![CDATA[]]></box>"
  #     # end_content << '</page>'
  #     # BabyBookPage.update_all("position=position+1","baby_book_id = #{book.id} and position > 2")
  #     preface = BabyBookPage.create(:baby_book_id=>book.id,:layout_id=>32,:content=>preface_content)
  #     preface.insert_at(3)
  #     # end_page = BabyBookPage.create(:baby_book_id=>book.id,:layout_id=>32,:content=>end_content)
  #     puts "book #{book.name} is fine"
  #   end
  # end
  # desc "generate_preface_image"
  # task :generate_preface_image => [:environment] do
  #  BabyBook.all.each do |book|
  #     page = book.baby_book_pages.first :conditions=>["position = 3"]
  #     book.generate_page_image(page)
  #  end
  # end

  desc "refactor box size"
  task "resize_box" => [:environment] do
      BabyBook.all.each do |book|
      page = BabyBookPage.first :conditions=>["position = 3 and layout_id=32 and baby_book_id = #{book.id}"]
      doc=Nokogiri::XML(page.content)
      boxs=doc.xpath('/page/box').to_a.sort{|a,b|  a["layer"].to_i <=> b["layer"].to_i}
      boxs.each do |box|
        case box['type']
        when "text"
          box['w']='95'
          box['h']='70'
          box['x']='25'
          box['y']='70'
        end
      end
      page.content = doc.to_xml
      page.layout_id = 45
      page.save
      book.generate_page_image(page)
   end
  end
end
