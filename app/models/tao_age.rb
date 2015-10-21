class TaoAge < ActiveRecord::Base
  	has_and_belongs_to_many :tao_categories
  	has_and_belongs_to_many :tao_products

  	def self.json_attrs
	    %w{id tp month desc target introduce recommand}
  	end

	def as_json(options = {})
	    options[:only] = (options[:only] || []) + TaoAge.json_attrs
	    options[:include] ||= {:tao_categories=>{:only=>TaoCategory.json_attrs, :methods=>TaoCategory.json_methods}}
	    super options
	end
end
