class AddBeginTimeToGous < ActiveRecord::Migration
  def self.up
    add_column :gous, :begin_time, :datetime
    add_column :gou_brands, :banner, :string
    add_column :tuan_comments, :gou_brand_id, :integer
  end

  def self.down
    remove_column :tuan_comments, :gou_brand_id
    remove_column :gou_brands, :banner
    remove_column :gous, :begin_time
  end
end
