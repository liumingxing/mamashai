class CreateRecommandAdvertisements < ActiveRecord::Migration
  def self.up
    create_table :recommand_advertisements do |t|
      t.string :logo, :limit=>200
      t.string :link, :limit=>200
      t.string :name, :limit=>100
      t.text :content
      t.integer :user_id
      t.integer :position
      t.string :age, :limit=>200
      t.string :tp, :limit=>100
      t.timestamps
    end
  end

  def self.down
    drop_table :recommand_advertisements
  end
end
