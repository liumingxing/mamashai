class CreateMenus < ActiveRecord::Migration
  def self.up
    create_table :menus do |t|
       t.column :text, :string, :limit=>100
       t.column :url, :string, :limit=>100
       t.column :parent_id,  :integer
       t.column :position,  :integer
       t.column :hide,  :integer
       t.column :blank, :integer        
       t.timestamps
    end
   
    root = Mms::Menu.create(:text=>"所有功能")
  end

  def self.down
    drop_table :menus
  end
end
