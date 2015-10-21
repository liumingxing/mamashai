class CreateAdvertisementLogos < ActiveRecord::Migration
#  def self.up
#    create_table :advertisement_logos do |t|
#      t.integer :advertisement_id
#      t.string  :logo
#      t.string  :url
#      t.string  :title
#      t.string  :remark
#      t.timestamps
#    end
#
#    add_column :advertisements, :name, :string
#    add_column :advertisements, :code, :string
#    add_column :advertisements, :size, :string
#    add_column :advertisements, :num, :integer
#    remove_column :advertisements, :position, :description, :content
#  end

  def self.down
    drop_table :advertisement_logos
  end
end
