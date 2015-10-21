class CreateEbookForms < ActiveRecord::Migration
  def self.up
    create_table :ebook_forms do |t|
      t.integer :user_id
      t.string :bookname
      t.string :formname
      t.string :content, :limit=>4000
      t.timestamps
    end
    
    add_index :ebook_forms, :user_id
  end

  def self.down
    drop_table :ebook_forms
  end
end
