class CreateHttpRefers < ActiveRecord::Migration
  def self.up
    create_table :http_refers do |t|
      t.string :link, :limit=>500
      t.string :http_refer, :limit=>1000
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :http_refers
  end
end
