class CreateBookSubjects < ActiveRecord::Migration
  def self.up
    create_table :book_subjects do |t|
      t.integer :book_id
      t.integer :subject_id
      t.integer :subject_book_count, :default => 0

      t.timestamps
    end

    add_index :book_subjects, :book_id
    add_index :book_subjects, :subject_id
  end

  def self.down
    drop_table :book_subjects
  end
end
