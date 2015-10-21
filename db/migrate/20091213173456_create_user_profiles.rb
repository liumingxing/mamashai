class CreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :user_profiles, :force => true do |t|
      t.string :pub_infos,:limit=>20  
      t.string :real_name,:limit=>50
      t.string :idcard,:limit=>50
      t.string :school,:limit=>50
      t.string :company,:limit=>50
      t.string :content,:limit=>120
      t.integer :user_id
    end
    
  end

  def self.down
    drop_table :user_profiles
  end
end
