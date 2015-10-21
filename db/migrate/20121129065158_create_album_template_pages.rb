class CreateAlbumTemplatePages < ActiveRecord::Migration
  def self.up
    create_table :album_template_pages do |t|
      t.integer :album_template_id
      t.string :logo_phone
      t.string :logo_print
      t.text :json
      t.string :status, :default=>"run"
      t.timestamps
    end
  end

  def self.down
    drop_table :album_template_pages
  end
end
