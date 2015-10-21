class CreateFlurries < ActiveRecord::Migration
  def change
    create_table :flurries do |t|
      t.date :day
      t.integer :tp    #平台
      t.integer :a1    #总激活
      t.integer :a2	   #当天新增
      t.integer :a3    #当天活跃
      t.integer :a4    #当天运行
      t.float :a5      #当天人均运行
      t.float :a6	   #当天人均在线时长
      t.float :a7      #次日留存率
      t.timestamps
    end
  end
end
