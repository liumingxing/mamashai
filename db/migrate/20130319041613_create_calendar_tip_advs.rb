class CreateCalendarTipAdvs < ActiveRecord::Migration
  def self.up
    create_table :calendar_tip_advs do |t|
      t.string :code
      t.string :logo_iphone
      t.string :logo_ipad
      t.integer :tp 			#1 : 弹出网页 2 : 执行代码 3 : 显示网页
      t.string :url
      t.text :code
      t.string :status, :default=>"online"
      t.timestamps
    end

    CalendarTipAdv.create(:code=>'yun', :tp=>1)
    CalendarTipAdv.create(:code=>'0_3', :tp=>1)
    CalendarTipAdv.create(:code=>'3_6', :tp=>1)
  end

  def self.down
    drop_table :calendar_tip_advs
  end
end
