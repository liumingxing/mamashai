# -*- coding: utf-8 -*-
require 'nokogiri'
require 'ftools'

class BabyBook < ActiveRecord::Base
  validates_presence_of :name,:message=>'请输入宝贝图书名称'
  validates_length_of :name,:within => 1..10,:too_long=>'宝贝图书名称不能超过10个字',:too_short=>'请输入宝贝图书名称'
  has_many :baby_book_pages,:dependent => :delete_all,:order=>"position asc"
  has_many :baby_book_votes,:dependent => :delete_all
  belongs_to :front_cover,:class_name=>"BabyBookPage",:foreign_key=>"front_cover_page_id"
  belongs_to :back_cover,:class_name=>"BabyBookPage",:foreign_key=>"back_cover_page_id"
  belongs_to :user
  belongs_to :baby_book_theme
  
  upload_column :logo,:process => '1024x1024', :versions => {:thumb156 => "c156x156", :thumb400 => "395x395" }
  
  named_scope :is_match, :conditions=>["baby_books.is_match = ?",true], :order=>"baby_books.vote_count desc"

  def inner_pages_size
    return BabyBookPage.count(:conditions=>"baby_book_id = #{self.id}") -2 
  end

  def all_pages_size
    return BabyBookPage.count(:conditions=>"baby_book_id = #{self.id}")
  end
  
  def baby_book_pages_count
    return all_pages_size
  end

  def is_can_join_match?
    self.baby_book_pages_count >= 10  and self.logo.present?
  end
  
  def vote_rank
    BabyBook.count(:all,:conditions=>['is_match=? and vote_count > ?',true,self.vote_count],:order=>'vote_count desc')+1
  end
  
  def is_ip_can_vote?(ip,user)
    return true if user.id == 100 or user.id == 228
    ip_today = BabyBookVote.count(:all,:conditions=>['baby_book_id=? and ip=? and created_at > ?',self.id,ip,Date.today])
    ip_strs = ip.split('.') 
    ip_all = BabyBookVote.count(:all,:conditions=>['baby_book_id=? and ip like ? ',self.id,"#{ip_strs[0]}.#{ip_strs[1]}.#{ip_strs[2]}.%"])
    return (ip_today < 2 and ip_all < 10 and ip[0..5]!='113.12')
  end
  
  def is_can_vote?(user)
    return true if user.id == 100 or user.id == 228
    is_today_voted = BabyBookVote.find(:first,:conditions=>['baby_book_id=? and user_id=? and created_at > ?',self.id,user.id,Date.today])
    is_ten_voted = (BabyBookVote.count(:all,:conditions=>['baby_book_id=? and user_id=?',self.id,user.id]) >= 10)
    return (!is_today_voted && !is_ten_voted)
  end
  
  def generate_latex(page_id=nil,path=nil,filename=nil)
    unless path
      dir=File.join(RAILS_ROOT,"public","books")
      File.makedirs dir unless File.exist?(dir)
    else
      dir=path
      File.makedirs path unless File.exist?(path)      
    end
    
    latex_start=%{\\documentclass[twoside, a5paper, noindent]{article}
\\usepackage{graphicx,wallpaper,ctex}
\\usepackage[absolute]{textpos}
\\usepackage[margin=20mm]{geometry}
\\usepackage{fancyhdr}
\\DeclareGraphicsExtensions{.eps,.mps,.pdf,.jpg,.png}
\\DeclareGraphicsRule{*}{eps}{*}{}
\\CTEXnoindent
\\pagestyle{empty}
\\begin{document}
    }
    
    latex_end="\\end{document}"
    unless filename.present?
      if page_id.present?
        tex_file_name="#{self.id}_#{page_id}.tex"
      else
        tex_file_name="#{self.id}.tex"
      end
    else
      tex_file_name = "#{filename}.tex"
    end
    
    File.open(File.join(dir,tex_file_name),"w"){|f|
      f.puts latex_start
      f.puts generate_latex_page(self.front_cover) if self.front_cover.present? and page_id.blank?
      unless page_id.present?
        f.puts "\\setcounter{page}{1}\n"
        self.baby_book_pages.each do |page|
          unless is_cover_page?(page)
            f.puts "\\pagestyle{fancy}\n" 
            f.puts "\\fancyfoot{}" 
            f.puts "\\fancyfoot[LE,RO]{\\thepage}\n" 
            f.puts generate_latex_page(page)
          end
        end
        if self.baby_book_pages.size.odd?
          end_content =  '<?xml version="1.0"?>'
          end_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/end/html/1.jpg\" wallpaper=\"/images/baby_books/themes/end/pdf/1.png\" bgcolor=\"white\">"
          end_content << '</page>'          
          end_page = BabyBookPage.new(:baby_book_id=>self.id,:layout_id=>32,:content=>end_content)
          f.puts generate_latex_page(end_page)
        end
      else
        if page=self.baby_book_pages.find(page_id)
          f.puts(generate_latex_page(page))
        end
      end
      f.puts "\\pagestyle{empty}\n" 
      f.puts generate_latex_page(self.back_cover) if self.back_cover.present? and page_id.blank?
      f.puts latex_end
    }
  end
  
  def generate_latex_page(page)
    if page.content.present?
      doc=Nokogiri::XML(page.content)
      tex=[]
      boxs=doc.xpath('/page/box').to_a.sort{|a,b|  a["layer"].to_i <=> b["layer"].to_i}
      pagecolor= doc.root['bg_color'] || nil
      wallpaper = doc.root['wallpaper'] || nil
      wallpaper="#{File.join(::Rails.root.to_s,'public/',wallpaper)}" if wallpaper.present? and wallpaper!="null"
      tex << "\\pagecolor{blue}" if pagecolor.present?
      tex << "\\ThisCenterWallPaper{1}{#{wallpaper}}" if wallpaper.present? and wallpaper!="null"
      boxs.each do |box|
        tex << generate_latex_box(box) 
        tex << "\n\n\n\n"
      end
      tex << "\\null\\newpage"
      return tex.join("\n")
    end
  end
  
  def generate_latex_box(box)
    tex=[]
    tex << "\\begin{textblock*}{#{box['w']}mm}(#{box['x']}mm,#{box['y']}mm)\n"
    case box["type"]
    when "image"
      if box['src'].present?
        file_path=File.join(::Rails.root.to_s,"public",sanitize_file_path(box['src']))
        tex << "\\includegraphics[width=#{box['w']}mm,height=#{box['h']}mm]{#{file_path}}" if File.exist?(file_path)
      end
    when "text"
      tex << " \\zihao{#{box["font_size"]}} " if box["font_size"].present?
      tex << " \\heiti " if box["font_weight"].present?
      tex << " \\{#{box["font"]}} " if box["font"].present?
      tex << " \\textcolor[rgb]{#{parse_color(box['font_color'])}}{ " if box["font_color"].present?
      tex_content = sanitize_tex(box.content)
      tex_content = tex_content.gsub(/(< *[bB][rR] *\/?>)*$/,"")
      tex << tex_content.gsub(/< *[bB][rR] *\/?>/,"\\newline\n")
      tex << " }" if box["font_color"].present?
    when "mixed"
      tex << convert_img_tag(sanitize_tex(box.content))
    when "sys"
      tex << " \\zihao{#{box["font_size"]}} " if box["font_size"].present?
      tex << " \\heiti " if box["font_weight"].present?
      tex << " \\{#{box["font"]}} " if box["font"].present?
      tex << " \\textcolor[rgb]{#{parse_color(box['font_color'])}}{ " if box["font_color"].present?
      tex << sanitize_tex(box.content)
      tex << " }" if box["font_color"].present?
    end
    tex << "\\end{textblock*}"
    return tex
  end
  
  def generate_pdf(page_id=nil,path=nil,filename=nil)
    generate_latex(page_id,path,filename)
    unless filename.present?
      if page_id.present?
        tex_file_name="#{self.id}_#{page_id}.tex"
        pdf_file_name="#{self.id}_#{page_id}.pdf"
      else
        tex_file_name="#{self.id}.tex"
        pdf_file_name="#{self.id}.pdf"
      end
    else
      tex_file_name="#{filename}.tex"
      pdf_file_name="#{filename}.pdf"
    end

    unless path.present?
      dir = File.join(::Rails.root.to_s,"public","books")
    else
      dir = path
    end
  
    logger.info "cd #{dir} && xelatex -interaction=nonstopmode -papersize=a5 #{File.join(dir,tex_file_name)}"
    result=`cd #{dir} && xelatex -interaction=nonstopmode -papersize=a5 #{File.join(dir,tex_file_name)}`
    return File.join(dir,pdf_file_name)
  end
  

  def create_cover_and_back_cover
    cover_content = '<?xml version="1.0"?>'
    cover_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/#{self.baby_book_theme_id}/html/frontcover_1.jpg\" wallpaper=\"/images/baby_books/themes/#{self.baby_book_theme_id}/pdf/frontcover_1.png\" bgcolor=\"white\">"
    cover_content << "<box bg_color=\"white\" w=\"105\" x=\"22\" y=\"40\" src=\"\" font_size=\"\" type=\"image\" font_color=\"#000000\" font_weight=\"\" layer=\"1\" h=\"79\"/>"
    cover_content << "<box bg_color=\"white\" w=\"79\" x=\"47\" attr_name=\"name\" y=\"130\" font_size=\"2\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"10\"><![CDATA[#{self.name}]]></box>"
    cover_content << "<box bg_color=\"white\" w=\"79\" x=\"47\" attr_name=\"author1\" y=\"142\" font_size=\"4\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"6\"><![CDATA[编辑：#{self.author1}]]></box>"
    cover_content << "<box bg_color=\"white\" w=\"79\" x=\"47\" attr_name=\"author2\" y=\"150\" font_size=\"4\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"6\"><![CDATA[排版：#{self.author2}]]></box>"
    cover_content << '</page>'

    preface_content =  '<?xml version="1.0"?>'
    preface_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/preface/html/1.jpg\" wallpaper=\"/images/baby_books/themes/preface/pdf/1.png\" bgcolor=\"white\">"
    preface_content << "<box bg_color='white' w='95' x='25' y='70' font_size='' type='text' font_color='#000' font_weight='' layer='1' h='70'><![CDATA[]]></box>"
    preface_content << '</page>'
    
    user = self.user
    
    back_cover_content = '<?xml version="1.0"?>'
    back_cover_content << "<page name=\"\" bg_html_image=\"/images/baby_books/themes/#{self.baby_book_theme_id}/html/backcover_1.jpg\" wallpaper=\"/images/baby_books/themes/#{self.baby_book_theme_id}/pdf/backcover_1.png\" bgcolor=\"white\">'"
    back_cover_content << "<box bg_color=\"white\" w=\"79\" x=\"47\" attr_name=\"space_name\" y=\"45\" font_size=\"9\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"5\"><![CDATA[#{user.name}在妈妈晒]]></box>"
    back_cover_content << "<box bg_color=\"white\" w=\"79\" x=\"47\" attr_name=\"space_url\" y=\"50\" font_size=\"9\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"5\"><![CDATA[#{user.http_user_url}]]></box>"
    back_cover_content << "<box bg_color=\"white\" w=\"30\" x=\"110\" attr_name=\"author1\" y=\"180\" font_size=\"10\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"5\"><![CDATA[编辑：#{self.author1}]]></box>"
    back_cover_content << "<box bg_color=\"white\" w=\"30\" x=\"110\" attr_name=\"author2\" y=\"185\" font_size=\"10\" type=\"sys\" font_color=\"#000000\" font_weight=\"true\" layer=\"1\" h=\"5\"><![CDATA[排版：#{self.author2}]]></box>"
    back_cover_content << '</page>'

    ActiveRecord::Base.transaction do
      frontcover_layout = BabyBookLayout.first(:conditions=>["is_publish = 1 and name like :cover",{:cover=>"frontcover_%"}])
      cover = BabyBookPage.create(:baby_book_id=>self.id,:layout_id=>frontcover_layout.id,:content=>cover_content)
      backcover_layout = BabyBookLayout.first(:conditions=>["is_publish = 1 and name like :cover ",{:cover=>"backcover_%"}])
      back_cover = BabyBookPage.create(:baby_book_id=>self.id,:layout_id=>backcover_layout.id,:content=>back_cover_content)
      self.front_cover_page_id = cover.id
      self.back_cover_page_id = back_cover.id
      preface = BabyBookPage.create(:baby_book_id=>self.id,:layout_id=>45,:content=>preface_content)
      self.save
    end
  end
  
  def generate_image(page_id=nil,type=".jpg")
    dir=File.join(RAILS_ROOT,'public','books','preview')
    File.makedirs(dir) unless File.exist?(dir)
    generate_pdf(page_id)
    file_name="#{self.id}.pdf"
    
    image_name=File.join(dir,"book_#{self.id}_#{MamashaiTools::TextUtil.uuid}#{type}")
    
    result=`cd #{File.join(::Rails.root.to_s,"public","books")} && convert -density 300x300 -resize 800x600 -quality 90 #{File.join(RAILS_ROOT,"public","books",file_name)} #{image_name}`
    image_name.sub(/\.png$/,'*')
    return image_name.sub(/\.jpg$/,'*')
  end
  
  def generate_page_image(baby_book_page,type=".jpg")
    if File.exist?(File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', baby_book_page.id.to_s,'logo',"logo#{type}"))
      image_name = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', baby_book_page.id.to_s,'logo',"logo#{type}") 
      image_thumb_name = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', baby_book_page.id.to_s,'logo',"logo_thumb#{type}") 
    else
      image_name = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', baby_book_page.created_at.strftime("%Y-%m-%d"), baby_book_page.id.to_s,'logo',"logo#{type}") 
      image_thumb_name = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', baby_book_page.created_at.strftime("%Y-%m-%d"), baby_book_page.id.to_s,'logo',"logo_thumb#{type}")
    end
    FileUtils.mkdir_p(File.dirname(image_name)) unless File.exists?(File.dirname(image_name))
    generate_pdf(baby_book_page.id.to_s)
    file_name="#{self.id}_#{baby_book_page.id}.pdf" 
    result=`cd #{File.join(::Rails.root.to_s,"public","books")} && convert -density 300x300 -resize 800x600 -quality 90 #{File.join(RAILS_ROOT,"public","books",file_name)} #{image_name} && convert -density 72x72 -resize 58x82 -quality 90 #{image_name} #{image_thumb_name}`
    #logger.info "cd #{File.join(RAILS_ROOT,"public","books")} && convert -density 300x300 -resize 800x600 -quality 90 #{File.join(RAILS_ROOT,"public","books",file_name)} #{image_name} && convert -density 72x72 -resize 58x82 -quality 90 #{image_name} #{image_thumb_name}"
    BabyBookPage.update_all(["logo=?","logo#{type}"],["id=?",baby_book_page.id])
  end
  
  
  
  private
  
  def is_cover_page?(page)
    return true if front_cover.present? && front_cover.id==page.id
    return true if back_cover.present? && back_cover.id==page.id
  end
  
  def sanitize_file_path(path)
    return "not_found_pic.jpg" unless path.end_with?(".jpg") or path.end_with?(".png")
    sanitize_path=path.clone
    sanitize_path.gsub!(/[\n\s\=\,\<\>]/,'')
    return sanitize_path
  end
  
  def sanitize_tex(content)
    # latex spectial char
    #  $ # % ^ & _ { } ~ \
    sanitize_content=content.clone
    sanitize_content.gsub!(/([\#\$\%\^\&\~\_\{\}\\])/){|match|  "\\#{match}"}
    return sanitize_content
  end
  
  def convert_img_tag(content)
    replaces={}
    sanitize_content=content.clone
    sanitize_content.scan(/\<img.* \/\>/){|imgs|
      imgs.each do |match|
        includegraphic = ""
        src=match.scan(/src='(.+?)'/).first.first
        width=match.scan(/w='(.+?)'/).first.first
        height=match.scan(/h='(.+?)'/).first.first
        file_path=File.join(RAILS_ROOT,"public","books", sanitize_file_path(src) )
        includegraphic="\\includegraphics[width=#{width}mm,height=#{height}mm,keepaspectratio=true]{#{file_path}}" if File.exist?(file_path)
        replaces[match]=includegraphic
      end
    }
    
    replaces.each_pair do |match,includegraphic|
      sanitize_content.gsub!(match,includegraphic)
    end
    
    sanitize_content.gsub!(/\&lt;/,'<')
    sanitize_content.gsub!(/\&gt;/,'>')
    return sanitize_content
  end
  
  def parse_color(str)
    case str
    when /^#/
      str=str.sub(/^#/,'')
      if str.length < 6
        color=str.rjust(6,'0')
      else
        color=str
      end
      r=color[0..1].hex.to_s
      g=color[2..3].hex.to_s
      b=color[4..5].hex.to_s
      return "0.#{r},0.#{g},0.#{b}"
    when /^\d/
      return str.gsub(" ",'').split(",").map{|k| "0."+k}.join(",")
    end
  end

end
