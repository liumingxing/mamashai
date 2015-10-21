class ColumnChapter < ActiveRecord::Base
  belongs_to :column_book, :foreign_key=>"book_id"
  belongs_to :user
  has_one :post, :foreign_key=>"from_id", :conditions=>"`from`='column'"
  
  named_scope :published, :conditions=>"draft=0"
  
  validates_presence_of :book_id, :message=>"请选择一个栏目"
  validates_presence_of :title, :message=>"必须输入标题"
  validates_presence_of :content, :message=>"内容不能为空"
  
  def recent(limit=5)
    prev_chapters = ColumnChapter.find(:all, :conditions=>"book_id = #{self.book_id} and id < #{self.id} and draft=0", :limit=>2, :order=>"id desc").reverse 
    next_chapters = ColumnChapter.find(:all, :conditions=>"book_id = #{self.book_id} and id > #{self.id} and draft=0", :limit=>limit-2) 
    prev_chapters + next_chapters
  end
  
  def after_create
    author = ColumnAuthor.find_by_user_id(self.user_id)
    if author
      author.books = ColumnBook.count(:conditions=>"user_id=#{self.user_id}")
      author.chapters = ColumnChapter.count(:conditions=>"user_id = #{self.user_id}")
      author.save
    end
  end
  
  def post_id
    self.post.id if self.post
  end
  
  def book_name
    self.column_book.name if self.column_book
  end
  
  def refer_time
    from_time = self.updated_at
    to_time = Time.new
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    include_seconds = false
    case distance_in_minutes
      when 0..1
      return "1 #{APP_CONFIG['time_label_minute']}" unless include_seconds
      case distance_in_seconds
        when 0..5   then "5#{APP_CONFIG['time_label_second']}"
        when 6..10  then "10#{APP_CONFIG['time_label_second']}"
        when 11..20 then "20#{APP_CONFIG['time_label_second']}"
        when 21..40 then "#{APP_CONFIG['time_label_half_min']}"
        when 41..59 then "1#{APP_CONFIG['time_label_minute']}"
      else             "1#{APP_CONFIG['time_label_minute']}"
      end
      when 2..45      then "#{distance_in_minutes}#{APP_CONFIG['time_label_minute']}"
      when 46..90     then "1#{APP_CONFIG['time_label_hour']}"
      when 91..1440   then "#{(distance_in_minutes.to_f / 60.0).round}#{APP_CONFIG['time_label_hour']}"
      when 1441..2880 then "#{APP_CONFIG['time_label_yes']}"
      when 2881..4320 then "#{APP_CONFIG['time_label_before']}"
    else 
      from_time.strftime("%Y-%m-%d")
    end
  end
  
  def self.json_methods
    %w{post}
  end
  
  
  #def to_json(options = {})
    #options[:methods] ||= ColumnChapter.json_methods
    #options[:include]  = {:book_id=>:book}
    #options[:include] ||= {:last_post=>{:only=>Post.json_attrs}, :user_kids=>{:only => UserKid.json_attrs, :methods=>UserKid.json_methods}}
 #   super options
  #end
  
  #def to_json(options = {})
    #options[:only] = ColumnChapter.column_names + ColumnChapter.json_attrs
    #p options[:only]
  #  options[:methods] ||= ColumnChapter.json_methods
  #  super options
  #end
end
