class AddTextQuestionLenToNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :text_answer_len, :integer
  end

  def self.down
    remove_column :na_profile, :text_answer_len
  end
end
