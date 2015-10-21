class TaobaoCategory < ActiveRecord::Base
  set_table_name :taobao_categories
  
  acts_as_tree
  
  has_many :products, :class_name=>Mms::TaobaoProduct, :order=>"products.id desc", :foreign_key=>"category_id"
  
  def self.roots
    Category.find(:all, :conditions=>"parent_id is null")
  end
  
  def products_count
    Mms::TaobaoProduct.count(:conditions=>"category_id = #{self.id}")
  end
  
  def other_category_ids
    roots = Category.roots
    roots.delete(self)
    res = []
    for root in roots
      res += root.category_ids
    end
    res 
  end
  
  def category_ids
    res = []
    if self.children.size > 0
      for child in self.children
        res += child.category_ids
      end
    end
    return res + [self.id]
  end

  def category_ids_with_age age
    res = []
    if self.children.size > 0
      for child in self.children
        unless child.age.blank?
          if child.age.split(",").include? age.to_s
            res += child.category_ids
          end
        end
      end
    end
    return res + [self.id]
  end
  
  #所有叶子节点
  def leaf_ids
    res = []
    if self.children.size > 0
      for child in self.children
        res += child.leaf_ids
      end
    else
      return [self.id]
    end
    return res
  end

  def get_root
    category = self
    while category.parent_id
      category = category.parent
    end
    category
  end

  def get_yun_root
    category = self
    pre = self
    while category.parent_id
      pre = category
      category = category.parent
    end
    pre
  end
end
