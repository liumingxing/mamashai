class AddAgeIntoTaobaoProduct < ActiveRecord::Migration
  def self.up
    add_column :taobao_products, :age, :string
  end

  def self.down
    remove_column :taobao_products, :age
  end
end
