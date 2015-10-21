require 'fileutils'
require 'RMagick'

module MamashaiTools
  class ImageUtil
    def initialize
    end
    
    def self.update_logos(obj,x,y,size,thumb_sizes)
      if obj and obj.logo 
        img = Magick::Image::read(File.join(::Rails.root.to_s, 'public', obj.logo.url)).first 
        img.crop!(x.to_i, y.to_i,size.to_i,size.to_i,true)
        thumb_sizes.each do |thumb_size|
          thumb = img.resize( thumb_size, thumb_size )
          thumb.write File.join(::Rails.root.to_s, 'public', obj.send("logo_thumb#{thumb_size}").url) 
        end
        img.write File.join(::Rails.root.to_s, 'public', obj.logo.url) 
      end
    end 
    
    def self.update_page_picture(book_page,width,height,left,top)
      post = book_page.post
      if post and post.logo 
        post_logo_thumb400 = Magick::Image::read(File.join(::Rails.root.to_s, 'public', post.logo_thumb400.url)).first 
        post_logo = Magick::Image::read(File.join(::Rails.root.to_s, 'public', post.logo.url)).first 
        width1 = post_logo.columns
        width2 = post_logo_thumb400.columns
        page_logo_web = post_logo_thumb400.crop(left.to_i, top.to_i,width.to_i,height.to_i,true)
        page_logo = post_logo.crop(left.to_i*width1/width2, top.to_i*width1/width2,width.to_i*width1/width2,height.to_i*width1/width2,true)
        
        book_page.logo = post.logo
        book_page.save
        
        page_logo_web.write File.join(::Rails.root.to_s, 'public', book_page.logo_web.url) 
        page_logo.write File.join(::Rails.root.to_s, 'public', book_page.logo.url)
        
      end
    end 
    
    def self.update_cover_picture(user_book,post,width,height,left,top) 
      if post and post.logo 
        post_logo_thumb400 = Magick::Image::read(File.join(::Rails.root.to_s, 'public', post.logo_thumb400.url)).first 
        post_logo = Magick::Image::read(File.join(::Rails.root.to_s, 'public', post.logo.url)).first 
        width1 = post_logo.columns
        width2 = post_logo_thumb400.columns
        page_logo_web = post_logo_thumb400.crop(left.to_i, top.to_i,width.to_i,height.to_i,true)
        page_logo = post_logo.crop(left.to_i*width1/width2, top.to_i*width1/width2,width.to_i*width1/width2,height.to_i*width1/width2,true)
        
        user_book.logo = post.logo
        user_book.save
        
        page_logo_web.write File.join(::Rails.root.to_s, 'public', user_book.logo_web.url) 
        page_logo.write File.join(::Rails.root.to_s, 'public', user_book.logo.url)
      end
    end 
    
    def self.update_picture_cropper(page_id,thumb_url,img_url,width,height,left,top)
      logo_thumb = Magick::Image::read(File.join(::Rails.root.to_s, 'public', thumb_url)).first 
      logo = Magick::Image::read(File.join(::Rails.root.to_s, 'public', img_url)).first 
      width1 = logo.columns
      width2 = logo_thumb.columns
    # page_logo_web = logo_thumb.crop(left.to_i, top.to_i,width.to_i,height.to_i,true)
      page_logo = logo.crop(left.to_i*width1/width2, top.to_i*width1/width2,width.to_i*width1/width2,height.to_i*width1/width2,true)
      
    #  path1 = File.join(RAILS_ROOT, 'public', 'upload','babybookpage',page_id,'logo','web.jpg') 
    #  FileUtils.mkdir_p(File.dirname(path1)) unless File.exists?(File.dirname(path1))
    #  page_logo_web.write(path1)
    
      file_name = Time.now.strftime("%Y%m%d%H%M%S")+'.jpg'
     
      book = BabyBookPage.find(page_id).baby_book
      path1 = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', page_id,'logo', file_name)
      path2 = File.join(::Rails.root.to_s, 'public', 'upload','babybookpage', book.created_at.strftime("%Y-%m-%d"), page_id,'logo',file_name)
      path = File.exist?(path1) ? path1 : path2
      FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
      page_logo.write(path2)
      
      
      File.exist?(path1) ? "/upload/babybookpage/#{page_id}/logo/#{file_name}" : "/upload/babybookpage/#{book.created_at.strftime("%Y-%m-%d")}/#{page_id}/logo/#{file_name}"
    end
    
    # ======== 邮件群发，团购切图 ===========
    
    def self.update_tuan_email_picture(email, picture_root_path, height, type)
      picture = Magick::Image::read(File.join(::Rails.root.to_s, 'public', "#{email.picture}")).first
      picture_height  = picture.rows
      picture_num = (1 if (picture.rows / height) == 0) || ((picture.rows / height + 1 if picture.rows % height > 0) || picture.rows / height )
      height = (picture.columns if picture.columns < height ) || height
      top = 0
      images_path = ""
      (1..picture_num).each do |picture_num|
        height = picture.rows % height if picture_num == ((picture.rows / height + 1 if picture.rows % height > 0) || picture.rows / height )
        pictures = picture.crop(0, top, picture.columns, height, true)
        pictures.write File.join(picture_root_path, "picture_#{picture_num}.#{type}")
        top += height
        images_path += "/email/tuan_#{email.tuan_id}/picture_#{picture_num}.#{type};"
      end
      return images_path
    end
    
  end
end
