class ACategory < ActiveRecord::Base
  # attr_accessible :title, :body
  def first_four
  	AProduct.all(:limit=>4, :order=>"position desc, id desc", :conditions=>"hide = 0 and category_id = #{self.id}")
  end

  def self.json_attrs
    %w(id name created)
  end
  
  def as_json(options = {})
    options[:only] ||= ACategory.json_attrs
    options[:include] = {:first_four=>{:only=>AProduct.json_attrs, :methods=>AProduct.json_methods}}
    super options
  end
end
