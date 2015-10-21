class ALogo < ActiveRecord::Base
  # attr_accessible :title, :body
  upload_column :path ,:process => '800x800', :versions => {:thumb100 => "100x100", :thumb200 => "200x200", :thumb400 => "400x400", :thumb600 => "600x600"}

  validates_presence_of :path, :message=>"必须要上传logo"

  after_create :upload_to_aliyun

  def upload_to_aliyun
    return if !self.path
    return if !File.exist?(self.path.path)
    
    begin                     
      $connection.put("upload/alogo/#{self.id}/path/#{self.path.filename}", File.open(self.path.path), {:content_type => self.path.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/alogo/#{self.id}/path/#{self.path.thumb100.filename}", File.open(self.path.thumb100.path), {:content_type => self.path.thumb100.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/alogo/#{self.id}/path/#{self.path.thumb200.filename}", File.open(self.path.thumb200.path), {:content_type => self.path.thumb200.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/alogo/#{self.id}/path/#{self.path.thumb400.filename}", File.open(self.path.thumb400.path), {:content_type => self.path.thumb400.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
      $connection.put("upload/alogo/#{self.id}/path/#{self.path.thumb600.filename}", File.open(self.path.thumb600.path), {:content_type => self.path.thumb600.extension.downcase == 'png' ? "image/png" : "image/jpeg"})
    rescue
    end
  end

  def self.json_attrs
    %w(id created_at)
  end

  def logo_url
    self.path.try(:url)
  end
  
  def logo_thumb400
    self.path ? self.path.thumb400.url : nil
  end

  def logo_thumb600
    self.path ? self.path.thumb600.url : nil
  end
  
  def self.json_methods
    %w{logo_url logo_thumb400 logo_thumb600}
  end

  def as_json(options = {})
    options[:only] ||= ALogo.json_attrs
    options[:methods] ||= ALogo.json_methods
    super options
  end
end
