class AddQueueToTaobaoProduct < ActiveRecord::Migration
  def self.up
    add_column :taobao_products, :is_top, :integer, :default => 0

#    TaobaoProduct.all.each do |p|
#      p.update_attribute :is_top, 0
#    end
  end


  def self.down
    remove_column :taobao_products, :is_top
  end
end
