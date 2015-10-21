class AddIsExpertToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_expert, :boolean, :default=>false
    add_column :posts, :expert_user_id, :integer
  end
  
  def self.down
    remove_column :users, :is_expert
    remove_column :posts, :expert_user_id
  end
end
