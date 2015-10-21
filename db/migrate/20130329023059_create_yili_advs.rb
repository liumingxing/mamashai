class CreateYiliAdvs < ActiveRecord::Migration
  def self.up
    create_table :yili_advs do |t|
      t.string :ip
      t.timestamps
    end
  end

  def self.down
    drop_table :yili_advs
  end
end
