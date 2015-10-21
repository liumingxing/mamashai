class UserBook < ActiveRecord::Base 
  belongs_to :user
  belongs_to :user_order
  has_many :user_book_pages,:order=>'page_num',:limit=>66
  
  upload_column :logo,:process => '1024x1024',:versions => {:web => "116x116"}
  upload_column :file
  
  validates_presence_of :user_id
  
  def save_book_posts_order
    self.posts_order = ( self.posts_order == 'desc' ? 'asc' : 'desc' )
    self.save
  end
  
  ##################### functions #####################
  
  def self.init_user_book(user)
    user_book = UserBook.find_by_user_id(user.id)
    return user_book if user_book
    book_name = user.name
    first_kid = user.first_kid
    book_name = first_kid.name if first_kid
    user_book = UserBook.create(:user_id=>user.id,:posts_order=>'desc',:title=>"#{book_name}#{APP_CONFIG['user_book_title']}",:author1=>"#{user.name}",:author2=>"#{user.name}")
    return user_book 
  end 
  
  def self.add_book_post(user_book,post,user)
    ActiveRecord::Base.transaction do
      user_book_pages = user_book.user_book_pages
      UserBookPage.create(:user_book_id=>user_book.id,:post_id=>post.id,:content1=>"#{post.content}(#{MamashaiTools::TextUtil.date_cn(post.created_at)})",:page_num=>(user_book_pages.length + 1))
    end
  end
  
  def self.delete_book_page(user_book,book_page,user)
    return if book_page.blank?
    ActiveRecord::Base.transaction do
      user_book_pages = user_book.user_book_pages 
      UserBookPage.update_all(["page_num=(page_num-1)"],["user_book_id=? and page_num > ?",user_book.id,book_page.page_num])
      book_page.destroy
    end
  end
  
  def self.save_book_pages_sort(user_book,book_page_ids)
    ActiveRecord::Base.transaction do
      user_book.user_book_pages.each do |book_page|
        i = 1
        book_page_ids.each do |book_page_id|
          if book_page_id.to_i == book_page.id
            book_page.page_num = i
            book_page.save
          end
          i+=1
        end
      end
    end
  end
  
  
  def self.find_or_create_order(user_book,user)
    user_order = user_book.user_order
    unless user_order
      user_order = UserOrder.create_user_order(user,'book',{})
      user_book.user_order = user_order
      user_book.save
    end
    return user_order
  end
  
  
end
