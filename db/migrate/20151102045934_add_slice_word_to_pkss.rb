class AddSliceWordToPkss < ActiveRecord::Migration
  def change
    add_column :pksses, :slice_word, :string
  end
end
