class AddPostDescToPks < ActiveRecord::Migration
  def change
    add_column :pks, :post_desc, :string
    add_column :pks, :bold_desc, :string
  end
end
