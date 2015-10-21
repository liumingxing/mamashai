class CreateAgeWeekTags < ActiveRecord::Migration
  def self.up
  	create_table :week_tags do |t|
      t.integer :week_count, :default=>0
      t.integer :total_count, :default=>0
      t.string :description
      t.string :summary
      t.string :short_tag_name
      t.string :logo
      t.boolean :current, :default=>false
      t.timestamps
    end
  end

  def self.down
  	drop_table :week_tags
  end
end
