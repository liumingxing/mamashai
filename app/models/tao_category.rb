class TaoCategory < ActiveRecord::Base
  acts_as_tree

  belongs_to :logo_product, :class_name => "TaoProduct", :foreign_key=>"logo_product"
  
  has_many :products, :class_name=>'TaoProduct', :order=>"position desc, id", :foreign_key=>"category_id"
  #belongs_to :logo_product, :class_name=>"TaoProduct", :foreign_key=>"logo_product"
  has_and_belongs_to_many :tao_ages
  
  attr_accessor :age_id

  def children
    if self.code == "-1"
      @children ||= TaoCategory.all(:conditions=>"hide=0 and recommand=1 and (age is null or age like '%#{self.age_id}%')")
    else
      @children ||= TaoCategory.all(:conditions=>"parent_id = #{self.id}")
    end
  end

  def age_children
    if self.code == "-1"            #推荐类目
      @age_children = TaoCategory.all(:conditions=>"hide=0 and recommand=1 and (age is null or age like '%#{self.age}%')")
    else

      if self.age_id
        @age_children = TaoCategory.find(:all, :conditions=>"hide = 0 and parent_id = #{self.id} and (age is null or age like '%#{self.age_id}%')")
      else
        @age_children = TaoCategory.find(:all, :conditions=>"hide = 0 and parent_id = #{self.id}")
      end
    end
  end
  
  def products_count
    if self.code == "-1"
      cs = TaoCategory.all(:conditions=>"hide=0 and recommand=1 and (age is null or age like '%#{self.age_id}%')")
      TaoProduct.count(:conditions=>"category_id in (#{(cs.map{|c| c.id}<<-1).join(',')})")
    else
      TaoProduct.count(:conditions=>"category_id = #{self.id}")
    end
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

  def get_logo_product
    if self.children.size > 0
      product = TaoProduct.find(:first, :conditions=>"category_id in (#{self.children.map{|m| m.id}.join(',')})", :order=>"position desc, iid")
    else
      product = TaoProduct.find(:first, :conditions=>"category_id = #{self.id}", :order=>"position desc, iid")
    end
    
    if product
      TaoCategory.update_all "logo_product=#{product.id}", "id=#{self.id}" 
    end
  end

  #与商品图片挂钩
  def logo
    if self.logo_product
      product = TaoProduct.find_by_id(self.logo_product)
      return product.pic_url + "_120x120.jpg" if product
    else
      nil
    end
    nil
  end

  def self.json_attrs
    %w{id name code parent_id}
  end

  def self.json_methods
    %w(logo)
  end

  def as_json(options = {})
    return 'null' if self.blank?
    options[:only] = (options[:only] || []) + TaoCategory.json_attrs
    if self.children && self.children.size > 0 && (!self.parent || self.parent.id == 19)
      options[:methods] = (options[:methods] || []) + %w(age_children logo)
    else
      options[:methods] = (options[:methods] || []) + %w(logo)
    end
    #options[:include] ||= {:user_kids=>{:only => TaoCategory.json_attrs, :methods=>TaoCategory.json_methods}}
    super options
  end
end
