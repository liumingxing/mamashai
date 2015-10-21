class PostKid < ActiveRecord::Base
	belongs_to :kid, :class_name=>"UserKid", :foreign_key=>"kid_id"
	belongs_to :post, :class_name=>"Post", :foreign_key=>"post_id"
end
