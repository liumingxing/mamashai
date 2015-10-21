class APayment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :order, :class_name=>"AOrder"
end
