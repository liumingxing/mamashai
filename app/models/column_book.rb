class ColumnBook < ActiveRecord::Base
  belongs_to :user
  has_many :column_type
  has_many :chapters, :class_name=>"ColumnChapter", :foreign_key=>"book_id", :dependent => :delete_all
    
  def chapter_count
    return ColumnChapter.count :conditions=>"book_id = #{self.id}"
  end
  
  def comment_count
    Post.find_by_sql("select sum(comments_count) as s from posts where id in (#{(self.chapters.collect{|c| if c.post then c.post.id else -1 end }<<-1).join(',')})")[0]['s']
  end
  
  def after_create
    author = ColumnAuthor.find_by_user_id(self.user_id)
    if author
      author.books = ColumnBook.count(:conditions=>"user_id=#{self.user_id}")
      author.chapters = ColumnChapter.count(:conditions=>"user_id = #{self.user_id}")
      author.save
    end
  end
  
  def chapter_count
    ColumnChapter.count(:conditions=>"book_id = #{self.id}")
  end
  
  def self.json_methods
    %w{user chapter_count}
  end
  
  def as_json(options = {})
    options[:methods] ||= ColumnBook.json_methods
    super options
  end
end
