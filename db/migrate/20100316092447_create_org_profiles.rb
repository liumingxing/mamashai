class CreateOrgProfiles < ActiveRecord::Migration
  def self.up
    create_table :org_profiles do |t|
      t.string :tps,:limit=>50
      t.string :goal,:limit=>300
      t.string :content,:limit=>300
      t.string :blog_url,:limit=>200
      t.string :contact,:limit=>25
      t.string :qq,:limit=>50
      t.string :tel,:limit=>50
      t.string :mobile,:limit=>50
      t.string :email,:limit=>50
      t.string :msn,:limit=>50
      t.string :wangwang,:limit=>50
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :org_profiles
  end
end
