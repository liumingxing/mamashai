class TuanCategoryTemp < ActiveRecord::Base
  belongs_to :tuan_category
  has_many :tuans, :dependent => :delete_all
  
  after_create :log_for_create
  
  private
  
  def log_for_create
    logger.info "生成新的临时分类：#{self.name}" 
  end
end
