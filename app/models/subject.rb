class Subject < ActiveRecord::Base
  belongs_to :user
  has_one :gou_brand
  has_many :subject_user,:dependent => :delete_all
  has_many :book_subjects, :dependent => :delete_all
  has_many :books, :through => :book_subjects
  has_many :posts
  #has_one :post, :order =>"id desc"
  
  upload_column :logo,:process => '400x400', :versions => {:thumb155 => "c155x155", :thumb75 => "c75x75" }
  upload_column :banner,:process => '820x350'
  
  validates_length_of :name, :within => 1..20,:too_long=>'请输入20字以内的名字',:too_short=>'请输入20字以内的名字'
  validates_length_of :content, :within => 1..500,:too_long=>'请输入500字以内的简介',:too_short=>'请输入500字以内的简介'
  validates_presence_of :logo,:on=>:create,:message=>'请上传一张代表这个群组的图片'
  validates_uniqueness_of :name,:message=>'该群组已存在'
#  validates_format_of :banner, :with => %r{\.(gif|jpg|png|jpeg)$}i, :message => "必须为图片格式：gif|jpg|png|jpeg"
#  validates_integrity_of :banner

  def post
    return @post if @post
    posts = Post.not_hide.find(:all, :conditions=>"subject_id = #{self.id}", :limit=>2)
    if posts.size > 0
       @post = posts[0]
    else
       @post = null
    end
    return @post
  end
  
  def deputy
    return unless self.deputy_user_id
    begin
      User.find(self.deputy_user_id)
    rescue ActiveRecord::RecordNotFound
      return
    end
  end
  
  def deputy=(user)
    return  unless user.kind_of?(User)
    self.deputy_user_id = user.id
  end
  
  def delete_deputy
    self.update_attribute("deputy_user_id",nil)
  end
  
  def can_manage(user)
    return false unless user
    return Subject.count(:conditions=>["(user_id=? or deputy_user_id=?) and id=?",user.id,user.id,self.id]) > 0
  end

  def post_of_subject_last(last_number)
    last_subject =[]
    self.posts.all(:order => "id desc", :limit => last_number).each do |post|
      last_subject << "<b>#{post.user.name}</b>：#{post.content}"
    end
    last_subject
  end
end
