class Album < ActiveRecord::Base
  has_many :pictures
  belongs_to :user
  validates_presence_of :name, :message => '相册名称不能为空'
  validates_presence_of :access, :message => '访问权限不能为空'
  #named_scope :public,:conditions => ['access = ?', 'public']
  named_scope :except_private,:conditions => ['access != ?', 'private']
  upload_column :logo,:process => 'c130x97',:versions => {:thumb => "c60x45"}
  
  
  def set_cover(picture)
    return if self.logo
    if self.logo.blank?
      self.logo = picture.logo
      self.save
    end
  end
end
