class AddTextQuestionToNaProfile < ActiveRecord::Migration
  def self.up
    add_column :na_profiles, :text_question, :string, :limit=>200
    add_column :na_profiles, :text_answer, :text
  end

  def self.down
    remove_column :na_profiles, :text_question
    remove_column :na_profiles, :text_answer
  end
end
