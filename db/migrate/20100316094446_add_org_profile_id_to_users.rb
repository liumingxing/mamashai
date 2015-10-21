class AddOrgProfileIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :org_profile_id, :integer
    add_column :users, :rate, :float, :default=> 0 
    add_column :users, :rates_num, :integer,:default=>0
    add_column :user_signups, :org_tps, :string,:limit=>50
    add_column :user_signups, :org_name, :string,:limit=>50
    add_column :user_signups, :age_ids, :string,:limit=>20,:default=>''
    add_column :user_signups, :name, :string,:limit=>50
    add_column :user_signups, :mobile, :string,:limit=>20
    add_column :user_signups, :idcard, :string,:limit=>50
  end
  
  def self.down
    remove_column :users, :org_profile_id
    remove_column :users, :rate
    remove_column :users, :rates_num
    remove_column :user_signups, :org_tps
    remove_column :user_signups, :org_name
    remove_column :user_signups, :age_ids
    remove_column :user_signups, :name
    remove_column :user_signups, :mobile
    remove_column :user_signups, :idcard
  end
end
