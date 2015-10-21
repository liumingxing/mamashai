class CreateLinkTags < ActiveRecord::Migration
  def self.up
    create_table :link_tags, :force => true do |t|
      t.string :name,:limit=>20
      t.integer :link_category_id
    end
  end

  def self.down
  end
end
