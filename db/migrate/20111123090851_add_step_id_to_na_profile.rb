class AddStepIdToNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :step_id, :integer
  end

  def self.down
    remove_column :na_profiles, :step_id
  end
end
