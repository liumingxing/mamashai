class Mms::TaobaoProduct < ActiveRecord::Base
  has_many :comments, :class_name=>"TaobaoComment", :foreign_key=>"product_id", :order=>"created_at desc"
end
