class CreateOrgBranches < ActiveRecord::Migration
  def self.up
    create_table :org_branches do |t|
      t.string :name
      t.string :location
      t.float :longitude
      t.float :latitude
      t.integer :user_id

    end
  end

  def self.down
    drop_table :org_branches
  end
end
