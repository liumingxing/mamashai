class AReport < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :a_product
end
