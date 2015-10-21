class ChangeColumnTypeSeriesBookIdsToInteger < ActiveRecord::Migration
  def self.up
    change_column :books, :series_book_ids, :integer
  end

  def self.down
    change_column :books, :series_book_ids, :string
  end
end
