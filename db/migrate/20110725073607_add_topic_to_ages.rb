class AddTopicToAges < ActiveRecord::Migration
  def self.up
    add_column :ages, :topic, :string, :limit=>400
  end

  def self.down
    remove_column :ages, :topic
  end
end
