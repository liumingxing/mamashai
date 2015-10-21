class CreatePictureEditors < ActiveRecord::Migration
  def self.up
    create_table :picture_editors do |t|
      t.string :logo,:limit=>50
      t.references :user
      t.references :mms_user
      t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :picture_editors
  end
end
