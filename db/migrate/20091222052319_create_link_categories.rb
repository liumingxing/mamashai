class CreateLinkCategories < ActiveRecord::Migration
  def self.up
    create_table :link_categories, :force => true do |t|
      t.string :name,:limit=>20
    end
  end

  def self.down
  end
end
