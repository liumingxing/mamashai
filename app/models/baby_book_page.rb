# -*- coding: utf-8 -*-
class BabyBookPage < ActiveRecord::Base
  validates_presence_of :baby_book_id
  acts_as_list :scope=>:baby_book_id
  belongs_to :baby_book_layout, :foreign_key=>:layout_id
  
  belongs_to :baby_book,:counter_cache => true
  
  upload_column :logo,:process => '1024x1024',:versions => {:thumb600=>"423x600", :web => "310x310",:thumb=>"58x82"}, :store_dir=>proc{|record, file| if File.directory?("public/upload/babybookpage/#{record.id}/logo") then "babybookpage/#{record.id}/logo" else "babybookpage/#{record.created_at.strftime("%Y-%m-%d")}/#{record.id}/logo" end }
  
  def is_cover_page?
    return true if self.baby_book.front_cover_page_id==self.id
    return true if self.baby_book.back_cover_page_id==self.id
  end

  def is_frontcover?
    return self.baby_book.front_cover_page_id==self.id
  end

  def is_backcover?
    return self.baby_book.back_cover_page_id==self.id
  end
  
  def page_html
    doc=Nokogiri::XML(self.content)
    html=[]
    pagecolor= doc.root['bg_color'] || "transparent"
    root = doc.root
    wallpaper = doc.root['wallpaper'] || nil
    html << "<div page_id=#{self.id} "
    html << " bg_pdf_image='#{root['wallpaper']}' "
    html << " bg_html_image='#{root['bg_html_image']}' "
    html << " style='"
    html << "background:#{pagecolor}"
    html << " url(#{root['bg_html_image']}) no-repeat scroll 0 0; " if wallpaper
    html << "position:relative;"
    html << "width:148mm;" 
    html << "height:210mm;" 
    html << "font-size:10pt;" 
    html << "margin:auto;" 
    html << "'>"
    boxs=doc.xpath('/page/box').to_a.sort{|a,b|  a["layer"].to_i <=> b["layer"].to_i}
    boxs.each do |box|
      case box['type']
        when "image"
        if box['src'].present?
          html << "<div #{build_attr(box)}  style='#{build_style(box)}'>"
          html << "<img src='#{box['src']}' style='width:#{box['w']}mm;height:#{box['h']}mm;' />" 
        else
          html << "<div #{build_attr(box)}  style='#{build_style(box)};background:#F1F1F1 url(/images/baby_books/img_tips.png) no-repeat scroll 0 0;'>"
        end
        when "text"
        if box.content.present?
          html << "<div #{build_attr(box)}  style='#{build_style(box)}'>"
          html << box.content
        else
          html << "<div #{build_attr(box)}  style='#{build_style(box)};background:transparent url(/images/baby_books/text_tips.png) no-repeat scroll 0 0;'>"
        end
        when "mixed"
        when "sys"
        html << "<div #{build_attr(box)}  style='#{build_style(box)}'>"
        html << box.content
      end
      html << "</div>"
    end
    html << "</div>"
    return html.join()
  end
  
  def page_position
    return position-2
  end

  private
  def build_style(box)
    style={}
    if box["font_size"].present?
      case box["font_size"]
      when "0"
        style["font-size"]="42pt"
      when "1"
        style["font-size"]="28pt"
      when "2"
        style["font-size"]="21pt"
      when "3"
        style["font-size"]="15.75pt"
      when "4"
        style["font-size"]="14pt"
      when "5"
        style["font-size"]="10.5pt"
      when "6"
        style["font-size"]="7.875pt"
      when "7"
        style["font-size"]="5.25pt"
      when "-0"
        style["font-size"]="36pt"
      when "-2"
        style["font-size"]="18pt"
      when "-4"
        style["font-size"]="12pt"
      when "-5"
        style["font-size"]="9pt"
      else
        style["font-size"]="9pt"        
      end
    else
      style["font-size"]="9pt"
    end
    style["overflow"]="hidden"
    style["display"]="block"
    style["line-height"] = "150%"
    style["width"]="#{box['w']}mm"
    style["height"]="#{box['h']}mm"
    style["z-index"]="#{box['layer'].to_i+100}"
    style["position"]="absolute"
    style["left"]="#{box['x']}mm"
    style["top"]="#{box['y']}mm"
    style["border"]="#{box["type"]=='text' ? '2px dotted #CCCCCC' : '2px solid #CCCCCC'}"
    if box['font_color'].present?
      case box['font_color'] 
        when /^#/
          style["color"]=box['font_color'] 
        when /^\d/
          style["color"]="rgb(#{box['font_color']})" 
      end
    end
    if box["font-weight"]=="true"
      style["font-weight"]="bold"
      style["font-family"]="黑体"
    end

    return style.map{|k,v| "#{k}:#{v}"}.join(";")
  end
  
  def build_attr(box)
    attr={}
    attr["tp"]="#{box['type']}" 
    attr["attr_name"]=box["attr_name"] if box["attr_name"].present? 
    attr["font_size"]=box["font_size"] if box["font_size"].present? 
    attr["font_weight"]=box["font_weight"] if box["font_weight"].present? 

    return attr.map{|k,v| "#{k}='#{v}'"}.join(" ")
  end
end






