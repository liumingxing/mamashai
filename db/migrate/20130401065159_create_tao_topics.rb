class CreateTaoTopics < ActiveRecord::Migration
  def self.up
    create_table :tao_topics do |t|
      t.string :title
      t.string :logo
      t.string :desc, :length=>500
      t.timestamps
    end
  end

  def self.down
    drop_table :tao_topics
  end
end
