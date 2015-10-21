class CreateTopicTagTypes < ActiveRecord::Migration
  def self.up
    create_table :topic_tag_types do |t|
      t.string :type_name

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_tag_types
  end
end
