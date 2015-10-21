class CreateLamaUploads < ActiveRecord::Migration
  def self.up
    create_table :lama_uploads do |t|
      t.integer :user_id
      t.string :logo
      t.timestamps
    end
  end

  def self.down
    drop_table :lama_uploads
  end
end
