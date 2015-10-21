# Methods added to this helper will be available to all templates in the application.
module BookHelper
  
  def book_page_pre_num(page_num)
    page_num = page_num - 2
    return ( page_num > 0 ? "?page=#{page_num}" : '' )
  end
  
  def book_logo_cropper_script(book_page)
    str = '<script type="text/javascript">show_page_picture_preview'
    layout_logos = {1=>'255,175',2=>'255,175',3=>'245,168',4=>'240,170',5=>'168,215',6=>'169,240',7=>'161,240',8=>'145,220',9=>'223,156',10=>'245,170'}
    if params[:action]=='edit_cover_picture_cropper'
      str += '(116,116);</script>'
    else
      str += "(#{layout_logos[book_page.layout]});</script>"
    end
    str
  end
  
  def book_cover_back_page(pages_count)
    add_num = (pages_count%2==0 ? 3 : 2)
    pages_count+add_num
  end
  
end
