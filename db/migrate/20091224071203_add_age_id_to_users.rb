class AddAgeIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :age_id, :integer,:default=>1
    add_column :users, :link_category_ids, :string, :limit=>30
  end
  
  def self.down
  end
end
