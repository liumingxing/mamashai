class Clap < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, :foreign_key=>"tp_id"
  belongs_to :album_book, :foreign_key=>"tp_id"

  after_create :make_comment_remind

  def make_comment_remind                   #对记录和照片书点赞，生成提醒
    if self.tp == 'post'                        
      CommentAtRemind.create(:tp=>"clap", :comment_id=>self.id, :user_id => self.post.user_id)
      MamashaiTools::ToolUtil.add_unread_infos(:create_clap, {:user => self.post.user})
    elsif self.tp == 'album'
      book = AlbumBook.find(self.tp_id)
      if book
        CommentAtRemind.create(:tp=>"clap", :comment_id=>self.id, :user_id => book.user_id)
        MamashaiTools::ToolUtil.add_unread_infos(:create_clap, {:user => book.user})
      end
    end
  end
  
  def self.count_of(tp, id)
    Clap.count(:conditions=>"tp='#{tp}' and tp_id = #{id}")
  end

  def user_name
  	self.user.name
  end

  def self.json_attrs
    [:id, :user_id]
  end

  # ==json_methods 输出方法
  # * logo_url: 图片地址
  # * logo_url_thumb99: 缩略图地址30x30
  #
  def self.json_methods
    %w{user_name}
  end
  
  def as_json(options = {})
    options[:only] ||= Clap.json_attrs
    options[:methods] ||= Clap.json_methods
    super options
  end
end
