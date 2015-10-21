class AddStepIdToMmsTools < ActiveRecord::Migration
  def self.up
    add_column :mms_tools, :step_id, :integer
  end

  def self.down
    remove_column :mms_tools, :step_id
  end
end
