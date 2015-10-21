class ColumnAuthor < ActiveRecord::Base
    belongs_to :user
    upload_column :img
    
  def count_of(tp)
      @tps = @tps || {}
      @tps[tp] = @tps[tp] || ColumnBook.find_by_sql("select sum(#{tp}) as c from column_books where user_id = #{self.user_id}")[0]['c'].to_i
  end
  
  def first_column
    ColumnBook.find(:first, :conditions=>"user_id=#{self.user_id}")
  end
  
  def latest_chapter
    ColumnChapter.find(:first, :conditions=>"user_id = #{self.user_id} and draft = 0 and access = 'public'", :order=>"id desc")
  end
  
  def self.json_attrs
    [:id, :user_id, :chapters, :books, :created_at, :updated_at, :desc]
  end
  
  def as_json(options = {})
    options[:only] ||= ColumnAuthor.json_attrs
    options[:methods] ||= [:user]
    super options
  end
  
  def self.json_methods
    %w{user}
  end

  #TODO 应该与 latest_chapter重构
  def latest_chapter_for_home_index(show_num, show_type = "part")
    sql_where = []
    sql_where << "user_id = #{self.user_id}"
    sql_where << "draft = 0"
    sql_where << "access = 'public'"
    sql_where << "short_title is not null" if show_type == "part"

    ColumnChapter.all(:limit => show_num, :conditions=> sql_where.join(" and "), :order=>"created_at desc")
  end

  def self.get_column_author_by_last_chapter(show_number, show_type = "part")
    sql_where = []
    sql_where << "column_chapters.draft = 0"
    sql_where << "column_chapters.access = 'public'"
    sql_where << "column_chapters.short_title is not null" if show_type == "part"
    ColumnAuthor.all(:joins => "inner join column_chapters on column_authors.user_id = column_chapters.user_id",
                     :group => "column_chapters.user_id",
                     :select =>  "max(column_chapters.created_at), column_chapters.user_id",
                     :order => "max(column_chapters.created_at) desc",
                     :limit => show_number,
                     :conditions => sql_where.join(" and "))
  end
end
