class AAddress < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  #身份证正反面
  upload_column :id_logo1 ,:process => '800x800', :versions => {:thumb200 => "200x200", :thumb400 => "400x400", :thumb600 => "600x600"}
  upload_column :id_logo2 ,:process => '800x800', :versions => {:thumb200 => "200x200", :thumb400 => "400x400", :thumb600 => "600x600"}

  def self.json_attrs
    %w(id user_id receiver mobile city address default id_name id_code created_at)
  end

  def logo_url1
    self.id_logo1.try(:url)
  end

  def logo_thumb200_1
    self.id_logo1 ? self.id_logo1.thumb200.try(:url) : nil
  end

  def logo_url2
    self.id_logo2.try(:url)
  end

  def logo_thumb200_2
    self.id_logo2 ? self.id_logo2.thumb200.try(:url) : nil
  end
  
  def self.json_methods
    %w{logo_url1 logo_url2 logo_thumb200_1 logo_thumb200_2}
  end

  def as_json(options = {})
    options[:only] ||= AAddress.json_attrs
    options[:methods] ||= AAddress.json_methods
    super options
  end
end
