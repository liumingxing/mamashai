class CreateColumn < ActiveRecord::Migration
  def self.up
    #专栏类型，比如营养健康类，情商教育类，孕期成长类，心灵成长类
    create_table :column_types do |t|
      t.string :name, :limit=>100
    end
    
    #专栏作家，不在users表设置标志位是因为怕用户数量增长后查询速度慢
    create_table :column_authors do |t|
      t.integer :user_id    #登录用户的id
      t.integer :books, :default=>0
      t.integer :chapters, :default=>0
      t.datetime :created_at
    end
    
    #专栏作家与专栏类型的关系表
    create_table :column_author_type do |t|
      t.integer :column_author_id
      t.integer :column_type_id
    end
    
    #专栏书目
    create_table :column_books do |t|
      t.integer :user_id      #作者id
      t.string :name          #书名
      t.text   :desc          #内容简介
      t.integer :visits, :default=>0 #访问次数
      t.integer :handclaps, :default=>0 #鼓掌数
      t.integer :column_type_id
      t.string :tags, :string, :limit=>200
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    #书的章节
    create_table :column_chapters do |t|
      t.integer :book_id    #书目id
      t.integer :user_id    #作者
      t.string :title       #章节标题
      t.text :content       #内容
      t.string :tag, :limit=>200
      t.string :access, :limit=>100   #公开性设置，值为 public, subject
      t.string :subject_id            #access为subject时，群组id
      t.boolean :draft, :default=>false
      t.integer :visited_times, :default=>0 #访问次数
      t.integer :claps, :default=>0  #鼓掌数
      t.timestamps
    end
    
    #专栏评论
    create_table :column_comments do |t|
      t.integer :user_id    #作者id
      t.integer :book_id    #数目id
      t.integer :chapter_id #章节id
      t.integer :commet_user_id #评论人
      t.text    :content    #评论内容
      t.datetime :created_at  #评论时间
    end
  end

  def self.down
    drop_table :column_types
    drop_table :column_authors
    drop_table :column_author_type
    drop_table :column_books
    drop_table :column_chapters
    drop_table :column_comments
  end
end
