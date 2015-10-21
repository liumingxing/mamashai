class BookMall < ActiveRecord::Base
  belongs_to :book
  belongs_to :gou_site
end
