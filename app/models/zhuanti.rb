class Zhuanti < ActiveRecord::Base
  upload_column :logo, :versions => {:web=>"c213x113"}
  upload_column :logo2, :versions => {:web=>"c310x287"}
  upload_column :logo3, :versions => {:web=>"c583x285"}
  
  def products_of(tag, limit=10, offset=0)
    ZtProduct.find(:all, :conditions=>"zt_id = #{self.id} and tag = '#{tag}'", :limit=>limit, :offset=>offset,:order=>"id desc")
  end
end
