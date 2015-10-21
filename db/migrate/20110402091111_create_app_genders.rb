class CreateAppGenders < ActiveRecord::Migration
  def self.up
    create_table :app_genders do |t|
      t.integer :qing, :default=>0
      t.integer :titai, :default=>0
      t.integer :fuqi, :default=>0
    end
  end

  def self.down
    drop_table :app_genders
  end
end
