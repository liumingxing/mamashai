class AgeTag < ActiveRecord::Base
  belongs_to :age
  belongs_to :tag
  upload_column :logo ,:process => '800x600', :versions => {:thumb90 => "c90x90"}

  def self.build_age_tags_csv
    csv=""
    Age.all.each do |age|
      post_tags=age.post_tags
      ask_tags=age.ask_tags
      csv << "#{age.name},post,#{build_tags_csv(post_tags)}\n"
      csv << "#{age.name},ask,#{build_tags_csv(ask_tags)}\n"
    end
    return csv
  end

  def self.rebuild_age_tags(csv)
    require 'csv'
    age_tags=CSV.parse csv
    return false unless is_validate_csv?(age_tags)
    ActiveRecord::Base.transaction do
      AgeTag.delete_all
      age_tags.each do |line|
        if age=Age.named(line[0].strip).first
          line.slice(2,line.size).each do |tag_name|
            tp=line[1].strip=="ask" ? 1 : 0
            begin
              if tag=Tag.named(tag_name).first
                age_tag=AgeTag.create :age_id=>age.id,:tag_id=>tag.id,:tp=>tp
              else
                tag=Tag.create(:name=>tag_name,:posts_count=>0)
                age_tag=AgeTag.create :age_id=>age.id,:tag_id=>tag.id,:tp=>tp
              end
            rescue 
              logger.info tag_name
              logger.info age_tag.errors.to_s
              return false
            end
          end
        end
      end
    end
  end
  
  # 默认图片地址450x450
  def logo_url
    logo.try(:url)
  end
  
  # 90x90 缩略图地址
  def logo_url_thumb90
    logo.try(:thumb90).try(:url)
  end

  def tag_name
    self.tag.name
  end
  
  def self.json_attrs
    [:id, :age_id, :tp, :created_at, :updated_at, :week_count, :description, :summary, :short_tag_name]
  end
  
  def self.json_methods
    %w{logo_url logo_url_thumb90 tag_name}
  end
  
  def as_json(options = {})
    return 'null' if self.blank?
    options[:only] ||= AgeTag.json_attrs
    options[:methods] = (options[:methods] || []) + AgeTag.json_methods
    super options
  end

  private

  def self.build_tags_csv(tags)
    line=""
    unless tags.blank?
      tag_names=tags.collect{|t| t.name}
      return tag_names.join(",")
    end
  end

  def self.is_validate_csv?(age_tags)
    age_tags.each do |line|
      line.compact!
      unless line.blank?
        return false if line.size < 3
        return false unless line[1].strip =~ /ask|post/
      else
        age_tags.delete line
      end
    end
    return true
  end
end
