class AddTextToImage
  def self.draw_user_info(old_image, new_image, text)
    image = Magick::Image.read(old_image).first
    draw = Magick::Draw.new
    #font_path = "lib/simsun.ttf"
    #draw.font = font_path
    draw.annotate(image,0,0,0,0,text) do
      self.gravity = Magick::CenterGravity
      self.pointsize = 13
      self.font_weight=Magick::BoldWeight
      self.fill='#FFFFFF'
      self.gravity=Magick::SouthEastGravity
      self.stroke = "none"
    end
    image.write(new_image)
    end
end