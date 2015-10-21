class AddEvalToCalendarAdvs < ActiveRecord::Migration
  def self.up
	add_column :calendar_advs, :url, :string
  end

  def self.down
  end
end
