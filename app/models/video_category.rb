class VideoCategory < ActiveRecord::Base
  acts_as_tree :foreign_key => "parent_video_category", :order=>"position"
  upload_column :logo ,:process => '400x400', :versions => {:thumb160 => "c160x98"}, :store_dir=>proc{|category, file| "video_category/#{category.created_at.strftime("%Y-%m-%d")}/#{category.id}/logo"}

  def refresh_video_count
  	if self.children.size == 0
  		self.video_resources_count = VideoResource.count :conditions=>"video_category_id = #{self.id}"
  	else
  		c = 0
  		for child in self.children
  			c += child.video_resources_count.to_i
  		end
  		self.video_resources_count = c
  	end

  	if self.parent
  		self.parent.refresh_video_count
  	end

  	self.save
  end

  def self.json_attrs
    [:id, :name, :video_resources_count]
  end
  
  def self.json_methods
    %w{logo_url logo_thumb160}
  end
  
  def logo_url
    self.logo.url if self.logo
  end
  
  def logo_thumb160
    self.logo.thumb160.url if self.logo
  end
  
  def as_json(options = {})
    options[:only] ||= VideoCategory.json_attrs
    options[:methods] ||= VideoCategory.json_methods

    if self.children.size > 0
      options[:methods] << "children"
    end
    super options
  end
end
