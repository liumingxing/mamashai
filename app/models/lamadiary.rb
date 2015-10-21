class Lamadiary < ActiveRecord::Base
  set_table_name :lamadiary
  belongs_to :lama, :foreign_key => "uid", :primary_key => "uid"
  upload_column :pic_path , :versions => {:thumb100=>"c100x138", :thumb50=>"c50x69"}
  
  def self.json_attrs
    %w{weather kaixin naoxin guanxin qushi}
  end
  
  #图片路径不必json输出了，因为post已经输出了
  def as_json(options = {})
    options[:only] ||= Lamadiary.json_attrs
    super options
  end
  
  def post
    Post.find(:first, :conditions=>"from_id = #{self.id} and `from` like 'lama_%'")  
  end
end
