class AddShortUrlToTaoProducts < ActiveRecord::Migration
  def self.up
  	add_column :tao_products, :short_url, :string, :limit=>30
  end

  def self.down
  end
end
