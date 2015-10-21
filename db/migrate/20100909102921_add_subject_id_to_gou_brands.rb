class AddSubjectIdToGouBrands < ActiveRecord::Migration
  def self.up
    add_column :gou_brands, :subject_id, :integer
  end

  def self.down
    remove_column :gou_brands, :subject_id
  end
end
