class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :business_id
      t.string :name
      t.string :branch_name
      t.string :logo
      t.string :logo_large
      t.string :province
      t.string :city
      t.string :address
      t.float  :price
      t.text   :json
      t.float  :latitude
      t.float  :longitude
      t.float  :avg_rating
      t.string :rating_s_img_url
      t.string :url
      t.timestamps
    end
  end
end
