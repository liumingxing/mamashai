require 'shopping_item'
class ShoppingCart < ActiveRecord::Base
  serialize :shopping_items ,Array
  belongs_to :user

end
