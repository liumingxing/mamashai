class CreateLamaPersonalTemplates < ActiveRecord::Migration
  def self.up
    create_table :lama_personal_templates do |t|
      t.integer :user_id
      t.string :preview_path
      t.string :small_path

      t.timestamps
    end
  end

  def self.down
    drop_table :lama_personal_templates
  end
end
