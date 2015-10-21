class CreatUserReports < ActiveRecord::Migration
  def self.up
    create_table :user_reports, :force => true do |t|
      t.string :url,:limit=>100
      t.string :content,:limit=>1000
      t.integer :user_id
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :user_reports
  end
end
