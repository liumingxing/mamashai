class CreateVirtualProducts < ActiveRecord::Migration
  def self.up
    create_table :virtual_products do |t|
      t.string :code
      t.string :password
      t.string :type
      t.integer :tp,:default=>0  #生成类型 0为商家提供编码，1为系统自动生成编码，无密码，2为系统自动生成编码和密码
      t.string :state
      t.string :name #商品名称
      t.string :info #商品描述
      t.string :shop #商家名称
      t.string :shop_phone #商家电话
      t.string :shop_info #商家信息
      t.string :address #消费地址
      t.integer :person_amount,:default=>0
      t.integer :sold_count,:default=>0
      t.integer :tuan_id
      t.date :begin_time
      t.date :end_time
      t.integer :limit_time
      t.timestamps
    end
    add_column :tuans, :virtual, :boolean,:default=>false
  end

  def self.down
    remove_column :tuans, :virtual
    drop_table :virtual_products
  end
end
