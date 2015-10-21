class ACommentLogo < ActiveRecord::Base
  # attr_accessible :title, :body
  upload_column :logo ,:process => '800x800', :versions => {:thumb100 => "100x100", :thumb200 => "200x200", :thumb400 => "400x400", :thumb600 => "600x600"}

  def self.json_attrs
    %w(id created_at)
  end

  def logo_url
    self.logo.try(:url)
  end
  
  def logo_thumb100
    self.logo ? self.logo.thumb100.url : nil
  end

  def logo_thumb200
    self.logo ? self.logo.thumb200.url : nil
  end

  def logo_thumb400
    self.logo ? self.logo.thumb400.url : nil
  end

  def logo_thumb600
    self.logo ? self.logo.thumb600.url : nil
  end
  
  def self.json_methods
    %w{logo_url logo_thumb100 logo_thumb200 logo_thumb400 logo_thumb600}
  end

  def as_json(options = {})
    options[:only] ||= ACommentLogo.json_attrs
    options[:methods] ||= ACommentLogo.json_methods
    super options
  end
end
