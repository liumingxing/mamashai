class AddStartDateToCalendarAdvs < ActiveRecord::Migration
  def change
    add_column :calendar_advs, :start_date, :date
    add_column :calendar_advs, :end_date, :date
    add_column :calendar_advs, :manually, :boolean, default: true
  end
end
