class ColumnCategory < ActiveRecord::Base
  def count
    ColumnAuthor.count(:conditions=>"category like '%#{self.id}%' and chapters >= 3")
  end

  def self.json_methods
    %w{count}
  end

  def as_json(options={})
     options[:methods] ||= ColumnCategory.json_methods
     super
  end
end
