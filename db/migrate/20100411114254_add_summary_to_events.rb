class AddSummaryToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :summary, :text
  end

  def self.down
    remove_column :events, :summary
  end
end
