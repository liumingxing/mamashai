class AddBannerToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :banner, :string,:limit=>150
  end

  def self.down
    remove_column :subjects, :banner
  end
end
