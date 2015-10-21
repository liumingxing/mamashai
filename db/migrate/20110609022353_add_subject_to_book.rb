class AddSubjectToBook < ActiveRecord::Migration
  def self.up
    add_column :books, :my_subjects, :string
  end

  def self.down
    remove_column :books, :my_subjects
  end
end
