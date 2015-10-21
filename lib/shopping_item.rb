# -*- coding: utf-8 -*-
class ShoppingItem
  # attachment 宝贝图书的pdf路径
  # desc 宝贝图书的名称
  attr_accessor :product_id,:amount,:attachment,:desc,:item_id
  def initialize(product_id,amount,attachment=nil,desc=nil,item_id=nil)
    @product_id=product_id
    @amount=amount
    @attachment=attachment
    @item_id=item_id
    @desc=desc
  end

  def product
    return @product = Product.find(@product_id)
  end
end
