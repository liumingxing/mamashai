class CreateAgeTags < ActiveRecord::Migration
  def self.up
    create_table :age_tags do |t|
      t.integer :age_id
      t.integer :tag_id
      t.integer :tp
      t.timestamps
    end 
    add_index :age_tags,[:age_id,:tag_id,:tp], :unique => true 
  end

  def self.down
    drop_table :age_tags
  end
end
