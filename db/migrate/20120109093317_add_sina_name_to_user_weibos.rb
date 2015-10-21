class AddSinaNameToUserWeibos < ActiveRecord::Migration
  def self.up
    add_column :user_weibos, :sina_name, :string, :length=>50
  end

  def self.down
  end
end
