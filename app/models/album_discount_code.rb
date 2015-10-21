class AlbumDiscountCode < ActiveRecord::Base
	belongs_to :order, :class_name=>AlbumOrder
end
