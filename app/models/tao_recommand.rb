class TaoRecommand < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :tao_product
end
